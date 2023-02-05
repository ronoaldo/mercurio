#!/usr/bin/bash
# Restore from a given backup file into the db service.

# Exit on any error
set -e -o pipefail
[ x"$DEBUG" == x"true" ] && set -x

BASEDIR=`readlink -f $(dirname $0)/../`
BASENAME=`basename $BASEDIR`

# Log with timestamps for measuring time.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $BASENAME: $@"
}

# Requires positional arg from 
FILE=$1
case $FILE in
    "latest")
        export FILE=s3://backups/mercurio.current.tar.gz
    ;;
esac
if [ x"$FILE" = x"" ] ; then
    log "Error: no file provided. "
    exit 1
fi

# Allow to restore from GCS
case $FILE in
    gs://*)
        log "Fetching from Cloud Storage ..."
        gsutil -m cp $FILE /tmp/restore.tar.gz
        export FILE=/tmp/restore.tar.gz
        log "Done. Using $FILE to restore."
    ;;
    s3://*)
        log "Fetching from S3 Storage ..."
        s3cmd get --continue $FILE /tmp/restore.tar.gz
        export FILE=/tmp/restore.tar.gz
        log "Done. Using $FILE to restore."
    ;;
esac

# Only keep the container server running
log "Shutting services down"
docker-compose down

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
AUX=.minetest/world.$TIMESTAMP
log "Moving current world dir to $AUX"
sudo mv .minetest/world $AUX
AUX=.minetest/db.$TIMESTAMP
log "Moving current db dir to $AUX"
sudo mv .minetest/db $AUX

log "Starting database with empty structure"
docker-compose up -d db
sleep 10

# Extract the world folder from backup
log "Restoring world from backup ... "
sudo tar xvf $FILE .minetest/world

# Restore the database from backup
log "Restoring database. This may take a long time"
tar -xOf $FILE .minetest/db.sql.gz | gunzip -c | docker-compose exec -T db psql -U mercurio

# Fix permissions after restore
log "Fixing permissions after restore"
make fix-perms

log "Server restore completed"

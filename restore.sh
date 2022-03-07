#!/usr/bin/bash
# Restore from a given backup file into the db service.

# Exit on any error
set -e
BASEDIR=`readlink -f $(dirname $0)`
BASENAME=`basename $BASEDIR`

# Log with timestamps for measuring time.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $BASENAME: $@"
}

# Requires positional arg from 
FILE=$1
if [ x"$FILE" = x"" ]; then
    log "Error: no file provided"
    exit 1
fi

# Allow to restore from GCS
case $FILE in
    gs://*)
        log "Fetching from Cloud Storage ..."
        gsutil -m --quiet cp $FILE /tmp/restore.tar.gz
        export FILE=/tmp/restore.tar.gz
        log "Done. Using $FILE to restore."
    ;;
esac

# Only keep the container server running
log "Shutting services down"
docker-compose down
log "Starting database"
docker-compose up -d db

# Move current world folder to timestamped one
AUX=.minetest/world.$(date +%Y%m%d-%H%M%S)
log "Moving current world dir to $AUX"
sudo mv .minetest/world $AUX

# Extract the world folder from backup
log "Restoring world from backup ... "
sudo tar xvf $FILE .minetest/world

# Restore the database from backup
log "Restoring database. This may take a long time"
tar xf $FILE .minetest/sql.gz | gunzip -c | docker-compose exec -T db psql -U mercurio

# Fix permissions after restore
log "Fixing permissions after restore"
make fix-perms

# Restart services back
log "Starting services back"
make run

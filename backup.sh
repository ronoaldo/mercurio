#!/bin/bash
set -e
set -o pipefail
[ x"$DEBUG" == x"true" ] && set -x

# Config
BASEDIR=`readlink -f $(dirname $0)`
BASENAME=`basename $BASEDIR`
BACKUP_DIR=$HOME/backups/$(date +'%Y%m')
BACKUP_FILE=$BACKUP_DIR/$BASENAME-$(date +'%Y%m%d-%H%M%S').tar

# Log with timestamps for measuring time.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $BASENAME: $@"
}

# Ensure we clean the temp db.sql file which is HUGE
_cleanup() {
    echo "Cleaning up ..."
    cd $BASEDIR
    rm -vf .minetest/db.sql .minetest/db.sql.gz .minetest/db.pg_dump.tar
}

# Main

# Separete from previous logs
echo ; echo ; echo

# On exit callback - cleanup files
trap "_cleanup" EXIT KILL

log "Saving backup to $BACKUP_FILE ..."

log "Entering $BASEDIR, and sourcing $BASEDIR/.env"
cd $BASEDIR
# Replace docker-compose env definitions with bash compatible definitions
sed -e 's/=/="/' -e 's/=\(.*\)$/\0"/' < .env > .env.sh
. .env.sh
rm .env.sh

log "Initializing $BACKUP_DIR"
mkdir -p $BACKUP_DIR

log "Exporting compressed SQL file ..."
docker-compose exec -T db pg_dump -c -U mercurio | gzip --fast -c > .minetest/db.sql.gz

log "Creating backup archive $BACKUP_FILE ..."
tar --exclude=mapserver.tiles --exclude=mapserver.sqlite -cvf $BACKUP_FILE .minetest/world .minetest/db.sql.gz

log "Removing backup file .minetest/db.sql.gz"
rm -vf .minetest/db.sql.gz

if [ x$MINETEST_BACKUP_GCS = x"true" ] ; then
    log "Copying backup to Cloud Storage ..."
    gsutil -m --quiet cp $BACKUP_FILE gs://minetest-hosting/servers/mercurio/backups/${BASENAME}.current.tar.gz
    export DO_REMOVE=true
fi

if [ x"$MINETEST_BACKUP_S3CMD" = x"true" ] ; then
    log "Copying backup to S3 Storage ..."
    s3cmd put --no-progress $BACKUP_FILE s3://backups/${BASENAME}.current.tar.gz 
    export DO_REMOVE=true
fi

if [ x"$DO_REMOVE" = x"true" ] ; then
    log "Removing local file to free space ..."
    rm -vf $BACKUP_FILE
fi

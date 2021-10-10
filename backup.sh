#!/bin/bash
set -e

# Config
BASEDIR=`readlink -f $(dirname $0)`
BASENAME=`basename $BASEDIR`
BACKUP_DIR=$HOME/backups/$(date +'%Y%m')
BACKUP_FILE=$BACKUP_DIR/$BASENAME-$(date +'%Y%m%d-%H%M%S').tar.gz

# Log with timestamps for measuring time.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $BASENAME: $@"
}

# Ensure we clean the temp db.sql file which is HUGE
_cleanup() {
    echo "Cleaning up ..."
    cd $BASEDIR
    rm -vf .minetest/db.sql .minetest/db.sql.gz
}

# Main

# Separete from previous logs
echo ; echo ; echo

# On exit callback - cleanup files
trap "_cleanup" EXIT KILL

log "Saving backup to $BACKUP_FILE ..."

log "Entering $BASEDIR, and sourcing $BASEDIR/.env"
cd $BASEDIR
. .env

log "Initializing $BACKUP_DIR"
mkdir -p $BACKUP_DIR

log "Exporting compressed SQL ..."
docker-compose exec -T db pg_dump -c -U mercurio | gzip --fast -c > .minetest/db.sql.gz

log "Creating backup archive $BACKUP_FILE ..."
tar --exclude=mapserver.tiles --exclude=mapserver.sqlite -cvzf $BACKUP_FILE .minetest/db.sql.gz .minetest/world

log "Removing backup file .minetest/db.sql.gz"
rm -vf .minetest/db.sql.gz

if [ x$MINETEST_BACKUP_GCS = x"true" ] ; then
    log "Moving backup to Cloud Storage ... "
    gsutil -m --quiet mv $BACKUP_FILE gs://minetest-hosting/servers/mercurio/backups/${BASENAME}.current.tar.gz
else
    log "Not moving to Cloud Storage. MINETEST_BACKUP_GCS env is not set to 'true'."
fi

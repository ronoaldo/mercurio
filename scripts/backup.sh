#!/bin/bash
set -e
set -o pipefail

[ x"$DEBUG" == x"true" ] && set -x

# Config
BASEDIR=`readlink -f $(dirname $0)/..`
BASENAME=`basename $BASEDIR`
BACKUP_DIR=$HOME/backups/$(date +'%Y%m')
BACKUP_FILE_NAME=$BASENAME-$(date +'%Y%m%d-%H%M%S').tar
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE_NAME}"
export LANG=C LC_ALL=C
# Include helper functions
source $BASEDIR/scripts/lib/all.sh

# Log with timestamps for measuring time.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $BASENAME: $@"
}

# Ensure we clean the temp db.sql file which is HUGE
_cleanup() {
    RET=$?
    log "Cleaning up (DO_REMOVE=${DO_REMOVE})... (exit_status=$RET)"
    
    cd $BASEDIR
    rm -vf .minetest/db.sql .minetest/db.sql.gz .minetest/db.pg_dump.tar
    if [ x"$DO_REMOVE" = x"true" ] ; then
        log "Removing local file to free space ${BACKUP_FILE} ..."
        rm -vf $BACKUP_FILE
    fi

    if [ x"$RET" != x"0" ]; then
        discord_message ":x: Backup execution failed."
    fi

    DISK_SPACE="$(df -h $PWD | grep -v 'Size' | awk  '{print $4", "$5}')"
    discord_message ":mag_right: Free disk space: $DISK_SPACE used"
}

# Main

# Separete from previous logs
echo ; echo ; echo

# On exit callback - cleanup files
trap "_cleanup" EXIT KILL

log "Entering $BASEDIR, and sourcing $BASEDIR/.env"
cd $BASEDIR
# Replace docker-compose env definitions with bash compatible definitions
sed -e 's/=/="/' -e 's/=\(.*\)$/\0"/' < .env > .env.sh
. .env.sh
rm .env.sh

log "Saving backup to $BACKUP_FILE ..."
discord_message ":vhs: Starting backup of '$BASENAME' ..."

log "Configured to export to GCS(${MINETEST_BACKUP_GCS}) / S3(${MINETEST_BACKUP_S3CMD}) cloud storage"
if [ x"$MINETEST_BACKUP_GCS" = x"true" -o x"$MINETEST_BACKUP_S3CMD" = x"true" ] ; then
    export DO_REMOVE=true
fi

log "Initializing $BACKUP_DIR"
mkdir -p $BACKUP_DIR

log "Exporting compressed SQL file ..."
docker-compose exec -T db pg_dump -c -U mercurio | gzip --fast -c > .minetest/db.sql.gz

log "Creating backup archive $BACKUP_FILE ..."
for i in $(seq 1 3) ; do
    log "> Attempt $i/3..."
    tar --exclude=mapserver.tiles --exclude=mapserver.sqlite \
        -cf $BACKUP_FILE \
        .minetest/world .minetest/db.sql.gz && break
    sleep $(( i * 2 ))
done

log "Removing backup file .minetest/db.sql.gz"
rm -vf .minetest/db.sql.gz

# Move backups to Cloud Storage if applicable
if [ x$MINETEST_BACKUP_GCS = x"true" ] ; then
    log "Copying backup to Cloud Storage ..."
    gsutil -m --quiet cp $BACKUP_FILE gs://minetest-backups/servers/mercurio/backups/${BASENAME}.current.tar.gz
fi

if [ x"$MINETEST_BACKUP_S3CMD" = x"true" ] ; then
    log "Copying backup to S3 Storage ..."
    s3cmd put --no-progress $BACKUP_FILE s3://backups/${BASENAME}.current.tar.gz 
fi

# Post to webhook, if configured to
log "Backup finished"
discord_message ":vhs: Backup finished: ${BACKUP_FILE_NAME}!"

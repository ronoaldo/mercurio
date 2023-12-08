#!/bin/bash
# shellcheck disable=SC1091

# Sanity checks, bashism setup
set -e
set -o pipefail
[ "$DEBUG" == "true" ] && set -x
export LANG=C LC_ALL=C

# Config
BASEDIR="$(readlink -f "$(dirname "$0")"/..)"
BASENAME="$(basename "$BASEDIR")"

BACKUP_DIR=$HOME/backups/$(date +'%Y%m')

BACKUP_FILE_NAME=$BASENAME-$(date +'%Y%m%d-%H%M%S')
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE_NAME}.world.tar"
DB_BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE_NAME}.db.sql.gz"

# Include helper functions
source "$BASEDIR/scripts/lib/all.sh"

# Log with timestamps for measuring time.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $BASENAME: $*"
}

# Ensure we clean the temp db.sql file which is HUGE
_cleanup() {
    RET=$?
    log "Cleaning up (DO_REMOVE=${DO_REMOVE})... (exit_status=$RET)"
    
    cd "$BASEDIR"
    if [ "$DO_REMOVE" = "true" ] ; then
        log "Removing local file to free space ${BACKUP_FILE} ${DB_BACKUP_FILE} ..."
        rm -vf "$BACKUP_FILE" "$DB_BACKUP_FILE"
    fi

    if [ x"$RET" != x"0" ]; then
        discord_message ":x: Backup execution failed."
    fi

    DISK_SPACE="$(df -h "$PWD" | grep -v 'Size' | awk  '{print $4", "$5}')"
    discord_message ":mag_right: Free disk space: $DISK_SPACE used"
}

# Main

# Separete from previous logs
echo ; echo ; echo

# On exit callback - cleanup files
trap "_cleanup" EXIT

log "Entering $BASEDIR, and sourcing $BASEDIR/.env"
cd "$BASEDIR"
# Replace docker-compose env definitions with bash compatible definitions
sed -e 's/=/="/' -e 's/=\(.*\)$/\0"/' < .env > .env.sh
. .env.sh
rm .env.sh

log "Saving backup to $BACKUP_FILE and $DB_BACKUP_FILE ..."
discord_message ":vhs: Starting backup of '$BASENAME' ..."

log "Configured to export to GCS(${MINETEST_BACKUP_GCS}) / S3(${MINETEST_BACKUP_S3CMD}) cloud storage"
if [ "$MINETEST_BACKUP_GCS" = "true" -o "$MINETEST_BACKUP_S3CMD" = "true" ] ; then
    log "Will remove temporary files on exit"
    export DO_REMOVE=true
fi

log "Initializing $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

log "Ensuring the db server is up"
docker-compose up --detach db

log "Creating database backup into $DB_BACKUP_FILE ..."
docker-compose exec -T db pg_dump -c -Fp -Z0 -U mercurio | gzip --fast -c > "$DB_BACKUP_FILE"
_size="$(du -sh "${DB_BACKUP_FILE}")"
log "Validating the resulting backup contents are valid (size=${_size})"
gunzip --test "${DB_BACKUP_FILE}"

log "Creating world backup archive $BACKUP_FILE ..."
for i in $(seq 1 3) ; do
    log "> Attempt $i/3..."
    tar \
        --exclude=mapserver.tiles \
        --exclude=mapserver.sqlite \
        --exclude='*area-export*' \
        --exclude='mercurio-export*' \
        -cf "$BACKUP_FILE" \
        .minetest/world && break
    sleep $(( i * 2 ))
done
_size="$(du -sh "${BACKUP_FILE}")"
log "Validating the resulting backup contents are valid (size=${_size})"
tar tf "${BACKUP_FILE}" >/dev/null

# Move backups to Cloud Storage if applicable
if [ "$MINETEST_BACKUP_GCS" = "true" ] ; then
    log "Copying backup to Cloud Storage ..."
    BUCKET="gs://minetest-backups/servers/mercurio/backups"
    log "Uploading world backup ..."
    gsutil --quiet cp "$BACKUP_FILE"    "${BUCKET}/${BASENAME}.current.world.tar"
    log "Uploading db backup ..."
    gsutil --quiet cp "$DB_BACKUP_FILE" "${BUCKET}/${BASENAME}.current.db.sql.gz"
fi

if [ "$MINETEST_BACKUP_S3CMD" = "true" ] ; then
    log "Copying backup to S3 Storage ..."
    log "Uploading world backup ..."
    s3cmd put --no-progress "$BACKUP_FILE" "s3://backups/${BASENAME}.current.world.tar"
    log "Uploading db backup ..."
    s3cmd put --no-progress "$DB_BACKUP_FILE" "s3://backups/${BASENAME}.current.db.sql.gz"
fi

# Post to webhook, if configured to
log "Backup finished"
discord_message ":vhs: Backup finished: ${BACKUP_FILE_NAME}!"

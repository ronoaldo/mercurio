#!/usr/bin/bash
# Restore from a given backup file into the db service.

# Exit on any error
set -e -o pipefail
[ "$DEBUG" == "true" ] && set -x

BASEDIR=$(readlink -f "$(dirname "$0")/../")
BASENAME=$(basename "$BASEDIR")

# Log with timestamps for measuring time.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $BASENAME: $*"
}

die() {
    log "$*"
    exit 1
}

# Requires positional arg from 
FILE=$1
DB_FILE=$2

[ -f "$FILE" ] || die "Missing world backup file"
[ -f "$DB_FILE" ] || die "Missing db backup file"

# Only keep the container server running
log "Shutting services down"
docker compose down

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
if [ -d .minetest/world ] ; then
    AUX=.minetest/world.$TIMESTAMP
    log "Moving current world dir to $AUX"
    sudo mv .minetest/world "$AUX"
fi
if [ -d .minetest/db ] ; then
    AUX=.minetest/db.$TIMESTAMP
    log "Moving current db dir to $AUX"
    sudo mv .minetest/db "$AUX"
fi

log "Starting database with empty structure"
docker compose up -d db
sleep 10

# Extract the world folder from backup
log "Restoring world from backup ... "
sudo tar xvf "$FILE" .minetest/world

# Restore the database from backup
log "Restoring database. This may take a long time"
gunzip -c "$DB_FILE" | docker compose exec -T db psql -U mercurio

# Fix permissions after restore
log "Fixing permissions after restore"
make fix-perms

log "Server restore completed"

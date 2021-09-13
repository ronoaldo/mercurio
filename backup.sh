#!/bin/bash

if [ -z $MINETEST_WORLD_DIR ]; then
    echo "MINETEST_WORLD_DIR not provided as environment variable."
    exit 1
fi

# Globals
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
YEAR_MONTH=$(date +%Y-%m)
BACKUP_DIR=${MINETEST_WORLD_DIR}/backups/${YEAR_MONTH}
WORLD_BACKUP=${BACKUP_DIR}/minetest_${TIMESTAMP}.tar.gz

# Copy original world file to restore later...
cd $MINETEST_WORLD_DIR
cp world.mt /tmp/world.mt

# Migrate from postgresql -> sqlite3 to create backup files
minetestserver --world $MINETEST_WORLD_DIR --migrate sqlite3
minetestserver --world $MINETEST_WORLD_DIR --migrate-players sqlite3
minetestserver --world $MINETEST_WORLD_DIR --migrate-auth sqlite3

# Strip auth information from world.mt
grep -v '^pgsql_' <world.mt >new.mt && mv new.mt world.mt

# Create compressed backup archive (with sqlite files)
mkdir -p $BACKUP_DIR
tar -cvzf $WORLD_BACKUP --exclude=mapserver.tiles --exclude=/backups/ ./

# Restores world.mt after backup, and cleanup sqlite files
cp /tmp/world.mt world.mt
rm -rvf {map,players,auth}.sqlite
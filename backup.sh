#!/bin/bash
set -e
set -x

BASEDIR=`readlink -f $(dirname $0)`
BASENAME=`basename $BASEDIR`
BACKUP_DIR=$HOME/backups/$(date +'%Y%m')
BACKUP_FILE=$BACKUP_DIR/$BASENAME-$(date +'%Y%m%d-%H%M%S').tar.gz

cd $BASEDIR
mkdir -p $BACKUP_DIR
docker-compose exec -T db pg_dump -c -U mercurio > .minetest/db.sql
tar --exclude=mapserver.tiles -cvzf $BACKUP_FILE .minetest/db.sql .minetest/world
rm -f .minetest/db.sql
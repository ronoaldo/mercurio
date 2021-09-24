#!/bin/bash
set -e
set -x

BASEDIR=`readlink -f $(dirname $0)`
BASENAME=`basename $BASEDIR`
BACKUP_DIR=$HOME/backups/$(date +'%Y%m')
BACKUP_FILE=$BACKUP_DIR/$BASENAME-$(date +'%Y%m%d-%H%M%S').tar.gz

echo "Saving backup to $BACKUP_FILE ..."
cd $BASEDIR
. .env
mkdir -p $BACKUP_DIR
docker-compose exec -T db pg_dump -c -U mercurio > .minetest/db.sql
tar --exclude=mapserver.tiles -cvzf $BACKUP_FILE .minetest/db.sql .minetest/world
rm -f .minetest/db.sql

if [ x$MINETEST_BACKUP_STORAGE = x"true" ] ; then
    echo "Moving backup to Cloud Storage ... "
    gsutil -m mv $BACKUP_FILE gs://minetest-hosting/servers/mercurio/backups/
fi
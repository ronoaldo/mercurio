#!/bin/bash
set -e

BASEDIR=`readlink -f $(dirname $0)`
BASENAME=`basename $BASEDIR`
BACKUP_DIR=$HOME/backups/$(date +'%Y%m')
BACKUP_FILE=$BACKUP_DIR/$BASENAME-$(date +'%Y%m%d-%H%M%S').tar.gz

# Ensure we clean the temp db.sql file which is HUGE
_cleanup() {
    echo "Cleaning up ..."
    cd $BASEDIR
    rm -vf .minetest/db.sql
}

trap "_cleanup" EXIT KILL

echo "Saving backup to $BACKUP_FILE ..."
cd $BASEDIR
. .env
mkdir -p $BACKUP_DIR
docker-compose exec -T db pg_dump -c -U mercurio > .minetest/db.sql
tar --exclude=mapserver.tiles -cvzf $BACKUP_FILE .minetest/db.sql .minetest/world
rm -vf .minetest/db.sql

if [ x$MINETEST_BACKUP_GCS = x"true" ] ; then
    echo "Moving backup to Cloud Storage ... "
    gsutil -m mv $BACKUP_FILE gs://minetest-hosting/servers/mercurio/backups/${BASENAME}.current.tar.gz
else
    echo "Not moving to Cloud Storage. MINETEST_BACKUP_GCS env is not set to 'true'."
fi
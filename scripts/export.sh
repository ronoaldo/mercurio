#!/bin/bash
set -e
set -x

BASEDIR="$(readlink -f "$(dirname "$0")/..")"
WORLD="${BASEDIR}/.minetest/world"
DEST="${BASEDIR}/.minetest/world/area-export"

export_map() {
    docker-compose up -d db
    sleep 5
    cp -v mapcleaner_protect.txt "${BASEDIR}/".minetest/world
    cd "${BASEDIR}/".minetest/world || exit 1
    rm -rf area-export
    mapcleaner --mode export_protected --export-all --batch-size 100000
    sqlite3 "${BASEDIR}/.minetest/world/area-export/map.sqlite" "select count(*) from blocks"
    cd "${BASEDIR}"
}

export_mods() {
    mkdir -p "${DEST}/worldmods/"
    cp -r mods/* mercurio "${DEST}/worldmods/"
    rm -rv "${DEST}/worldmods/discordmt"
}

export_config() {
    cp -r "${WORLD}"/mod_storage  "${DEST}"
    cp -r "${WORLD}"/map_meta.txt "${DEST}"
    cp -r "${WORLD}"/respawn.respawn.db "${DEST}"
    cat > "${DEST}"/world.mt <<EOF
enable_damage = false
creative_mode = true

backend = sqlite3

gameid = minetest
world_name = Mercurio-Export
EOF
}

export_map
export_mods
export_config

cd "${DEST}"
tar czf "${WORLD}"/mercurio-export.tar.gz ./

if [ "$1" = "--upload" ]; then
    cd "$BASEDIR"
    gcloud storage cp "${WORLD}"/mercurio-export.tar.gz gs://minetest-backups/servers/mercurio/backups/
    gcloud storage objects update \
        gs://minetest-backups/servers/mercurio/backups/mercurio-export.tar.gz \
        --add-acl-grant=entity=AllUsers,role=READER
fi
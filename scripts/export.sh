#!/bin/bash
set -e
[ "$DEBUG" = true ] && set -x

BASEDIR="$(readlink -f "$(dirname "$0")/..")"
WORLD="${BASEDIR}/.minetest/world"
DEST="${BASEDIR}/.minetest/world/area-export"

log()  { printf "[%s] [%s]: %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$1" "$2"; }
info() { log "INFO" "$*" ; }
warn() { log "WARN" "$*" ; }

export_map() {
    info "Exporting protected map area ... This may take a long time."
    docker-compose up -d db ; sleep 5
    cp -v mapcleaner_protect.txt "${BASEDIR}/".minetest/world
    cd "${BASEDIR}/".minetest/world || exit 1
    rm -rf area-export
    mapcleaner --mode export_protected --export-all --batch-size 200000
    sqlite3 "${BASEDIR}/.minetest/world/area-export/map.sqlite" "select count(*) from blocks"
    cd "${BASEDIR}"
}

export_mods() {
    info "Exporting server mods into worldmods ... "
    mkdir -p "${DEST}/worldmods/"
    cp -r mods/* mercurio "${DEST}/worldmods/"
    info "Removing incompatible mod discordmt ..."
    rm -r "${DEST}/worldmods/discordmt"
}

export_config() {
    info "Exporting server configuration ..."
    cp -r "${WORLD}"/mod_storage  "${DEST}"
    cp -r "${WORLD}"/map_meta.txt "${DEST}"
    cp -r "${WORLD}"/respawn.respawn.db "${DEST}"
    cat > "${DEST}"/world.mt <<EOF
enable_damage = false
creative_mode = true

backend = sqlite3

gameid = minetest
world_name = Mercurio-Export [${PKG_PREFIX}]
EOF
    cat > "${DEST}/news.md" <<EOF
# Exported Mercurio Server

This is the exported Mercurio Minetest server backup.

This export has the features: ${PKG_PREFIX}

Tips:

* Grant yourself all privileges with: /grantme all

This allows you to play with the protected regions!

Enjoy!
EOF
}

upload_to_gcs() {
    BUCKET=gs://minetest-backups/servers/mercurio/exports
    OBJECT="${BUCKET}/${PKG_NAME}"
    info "Uploading ${PKG_NAME} to ${OBJECT}..."

    cd "$BASEDIR"
    gcloud storage cp --quiet "${WORLD}/${PKG_NAME}" "${OBJECT}"
    gcloud storage objects update --add-acl-grant=entity=AllUsers,role=READER --quiet "${OBJECT}"
}

pkg_suffix() {
    SUFFIX=""
    if [ "$_EXPORT_MAP" == "true" ] ; then
        SUFFIX="${SUFFIX}_map"
    fi
    if [ "$_EXPORT_CONFIG" == "true" ] ; then
        SUFFIX="${SUFFIX}_config"
    fi
    if [ "$_EXPORT_MODS" == "true" ] ; then
        SUFFIX="${SUFFIX}_mods"
    fi
    echo "${SUFFIX}"
}

cleanup() {
    info "Cleaning up data at ${DEST}..."
    rm -rf "${DEST}"

    info "Cleannig up local ${PKG_NAME} ..."
    rm -f "${WORLD}/${PKG_NAME}"
}

usage() {
    cat <<EOF
$(basename "$0") - export server data

Usage: $0 [OPTIONS ...]

Where options can be:

--skip-map      Do not export map data
--skip-mods     Do not export mods to ${DEST}/worldmods
--skip-config   Do not export mod data/world configuration to ${DEST}
--skip-upload   Do not upload to cloud storage
--clean         Cleanup after the execution finishes
--help          Show this message and exit

EOF
    exit 1
}

# Main

# Default arguments
export \
    _EXPORT_MAP=true \
    _EXPORT_MODS=true \
    _EXPORT_CONFIG=true \
    _UPLOAD=true \
    _CLEANUP=false

# Parsing the arguments
while [ $# -gt 0 ] ; do
    case $1 in
        --skip-map)    export _EXPORT_MAP=false    ;;
        --skip-mods)   export _EXPORT_MODS=false   ;;
        --skip-config) export _EXPORT_CONFIG=false ;;
        --skip-upload) export _UPLOAD=false        ;;
        --clean)       export _CLEANUP=true        ;;
        --help|-h)     usage ;;
        *) warn "Invalid option: '$1'. Ignoring "  ;;
    esac
    shift
done

# Package name
PKG_PREFIX="mercurio-export$(pkg_suffix)"
PKG_NAME="mercurio-export$(pkg_suffix).tar.gz"
export PKG_NAME PKG_PREFIX

# Export data
info "Exporting map data to ${DEST} from ${WORLD}"
mkdir -p "${DEST}"
[ "$_EXPORT_MAP"    == "true" ] && export_map
[ "$_EXPORT_MODS"   == "true" ] && export_mods
[ "$_EXPORT_CONFIG" == "true" ] && export_config

# Package the exported world data
info "Packaging exported data into ${PKG_NAME}..."
cd "${DEST}"
tar czf "${WORLD}/${PKG_NAME}" ./

# Upload
[ "$_UPLOAD" == "true" ] && upload_to_gcs

# Cleanup on exit
[ "$_CLEANUP" == "true" ] && cleanup

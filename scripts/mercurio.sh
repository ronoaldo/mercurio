#!/bin/bash


# Apply all MERCURIO_* variables as substitutions to the configuration
# file from the environment passed to the container.
__configure() {
    env | grep ^MERCURIO_ | cut -f 1 -d= | while read e ; do
        echo "[mercurio] Configuring '$e' in '$1'"
        sed -e "s/\$($e)/${!e}/g" -i "$1"
    done
}

notify_crash() {
    # Build a formatted crash report in three messages to avoid
    # complex logic to handle with character limit of 2000 lines.
    discord_message "**Server Crashed** *Collecting logs...*"
    discord_message "$(
        echo "debug.txt:" ;
        echo '```';
        grep -E 'ERROR|WARNING' ${MINETEST_DEBUG_FILE} | grep -v 'api.telegram.org' | tail -n 10;
        echo '```';
    )"
    discord_message "$(
        echo "minetest.out:";
        echo '```';
        tail -n 10 ${MINETEST_STDERR_FILE} | grep -v 'api.telegram.org';
        echo '```';
    )"
}

log() {
    echo "[mercurio] $@"
}

# Always use configuration from the image, replacing credentials
# from environment
log "Starting server configuration"

cp -v /etc/luanti/world.mt /var/lib/mercurio/world.mt
cp -v /etc/luanti/news/*   /var/lib/mercurio/
__configure /var/lib/mercurio/world.mt
__configure /etc/luanti/luanti.conf

log "Server configured, launching."

if [ -f /usr/lib/scripts/all.sh ]; then
    source /usr/lib/scripts/all.sh
fi

# Log files stored in /var/logs/minetest
export LOGDIR=/var/logs/minetest
export MINETEST_STDERR_FILE=${LOGDIR}/minetest.out
export MINETEST_DEBUG_FILE=${LOGDIR}/debug.txt

# Launch run-loop for the server in a clean environment
while true ; do
    {
        echo -e "\n\n--- Separator ---\n\n" 
        log "Working directory: $PWD"
        log "Preparing to collect core dumps ..."
        ulimit -c unlimited  # Makes sure core dumps can be written with any size
        echo "$$" > pid      # Testing write access to $PWD
        rm -vf core          # Remove any previous core dumps
        /usr/bin/env -i HOME=/var/lib/luanti \
            luantiserver \
            --logfile ${MINETEST_DEBUG_FILE} \
            --world /var/lib/mercurio \
            --config /etc/luanti/luanti.conf
        echo -n "$?" > status
        log "Server shutdown with status code '$(cat status)'."
    } |& tee -a ${MINETEST_STDERR_FILE}
    EXIT_STATUS="$(cat status)"
    sleep 1
    if [ x"$EXIT_STATUS" != x"0" ] ; then
        if [ -f core* ]; then
            log "Found a core dump."
            mv -v core* ${LOGDIR}/core-$(date +%Y%m%d-%H%M%S).dump
        else
            log "No core dump found."
        fi
        sleep 1
        notify_crash
    else
        log "Server shutdown normaly."
    fi
    if [ x"$NO_LOOP" == x"true" ]; then
        log "Exiting script with status code $EXIT_STATUS "
        exit $EXIT_STATUS
    fi
    log "Restarting server in 10s..."
    sleep 10
done

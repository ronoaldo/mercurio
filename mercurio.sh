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
    CRASH_REPORT="$(
        echo -e "\n\ndebug.txt:" ;
        grep -E 'ERROR|WARNING' ${MINETEST_DEBUG_FILE} |
        grep -v 'api.telegram.org' |
        tail -n 8)"
    CRASH_REPORT="${CRASH_REPORT}$(
        echo -e "\n\nminetest.out:";
        tail -n 8 ${MINETEST_STDERR_FILE} |
        grep -v 'api.telegram.org')"
    discord_message "**Server crashed!**
\`\`\`
${CRASH_REPORT: -1950}
\`\`\`
Should restart soon."
}

log() {
    echo "[mercurio] $@"
}

# Always use configuration from the image, replacing credentials
# from environment
log "Starting server configuration"

cp -v /etc/minetest/world.mt /var/lib/mercurio/world.mt
cp -v /etc/minetest/news/*   /var/lib/mercurio/
__configure /var/lib/mercurio/world.mt
__configure /etc/minetest/minetest.conf

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
        /usr/bin/env -i HOME=/var/lib/minetest \
            minetestserver \
            --quiet \
            --logfile ${MINETEST_DEBUG_FILE} \
            --world /var/lib/mercurio \
            --config /etc/minetest/minetest.conf
        RET="$?"
    } |& tee -a ${MINETEST_STDERR_FILE}
    
    sleep 1
    if [ x"$RET" != x"0" ] ; then
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
        break
    fi
    log "Restarting server in 10s..."
    sleep 10
done

#!/bin/bash

echo "[mercurio] Starting"

# Apply all MERCURIO_* variables as substitutions to the configuration
# file from the environment passed to the container.
__configure() {
    env | grep ^MERCURIO_ | cut -f 1 -d= | while read e ; do
        echo "[mercurio] Configuring '$e' in '$1'"
        sed -e "s/\$($e)/${!e}/g" -i "$1"
    done
}

notify_crash() {
    CRASH_REPORT="$(echo -e "\n\ndebug.txt:\n" ; grep -E 'ERR|WARN' ${MINETEST_DEBUG_FILE} | tail -n 10)"
    CRASH_REPORT="${CRASH_REPORT}$(echo -e "\n\nminetest.out:\n"; tail -n 10 ${MINETEST_STDERR_FILE})"
    discord_message "**Server crashed!**
\`\`\`
${CRASH_REPORT: -1900}
\`\`\`
Should restart soon."
}

# Always use configuration from the image, replacing credentials
# from environment
cp -v /etc/minetest/world.mt /var/lib/mercurio/world.mt
cp -v /etc/minetest/news/*   /var/lib/mercurio/
__configure /var/lib/mercurio/world.mt
__configure /etc/minetest/minetest.conf

echo "[mercurio] Server configured, launching."

if [ -f /usr/lib/scripts/all.sh ]; then
    source /usr/lib/scripts/all.sh
fi

# Log files stored in /var/logs/minetest
export LOGDIR=/var/logs/minetest
export MINETEST_STDERR_FILE=${LOGDIR}/minetest.out
export MINETEST_DEBUG_FILE=${LOGDIR}/debug.txt

# Launch run-loop for the server in a clean environment
while true ; do
    echo -e "\n\n--- Separator ---\n\n" >> ${MINETEST_STDERR_FILE}
    /usr/bin/env -i HOME=/var/lib/minetest \
        minetestserver \
        --quiet \
        --logfile ${MINETEST_DEBUG_FILE} \
        --world /var/lib/mercurio \
        --config /etc/minetest/minetest.conf \
            2>&1 >> ${MINETEST_STDERR_FILE}
    RET="$?"
    sleep 1
    if [ x"$RET" != x"0" ] ; then 
        notify_crash
    fi
    if [ x"$NO_LOOP" == x"true" ]; then
        break
    fi
    echo "Restarting server in 10s..."
    sleep 10
done

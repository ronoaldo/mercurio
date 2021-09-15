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

# Always use configuration from the image, replacing credentials
# from environment
cp -v /etc/minetest/world.mt /var/lib/mercurio/world.mt
__configure /var/lib/mercurio/world.mt
__configure /etc/minetest/minetest.conf

echo "[mercurio] Server configured, launching."

# Launch run-loop wrapper in a clean environment
/usr/bin/env -i HOME=/var/lib/minetest \
    minetest-wrapper.sh \
    --world /var/lib/mercurio \
    --config /etc/minetest/minetest.conf
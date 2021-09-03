#!/bin/bash

# Apply all MERCURIO_* variables as substitutions to the configuration
# file from the environment passed to the container.
__configure() {
    env | grep ^MERCURIO_ | cut -f 1 -d= | while read e ; do
        echo "[mercurio] configuring $e in $1 ..."
        sed -e "s/\$($e)/${!e}/g" -i "$1"
    done
}
echo "[mercurio debug begin]"
env
echo "[mercurio debug end]"
# Always use configuration from the image, replacing credentials
# from environment
cp -v /etc/minetest/world.mt /var/lib/mercurio/world.mt
__configure /var/lib/mercurio/world.mt
__configure /etc/minetest/minetest.conf

# Launch run-loop wrapper in a clean environment
/usr/bin/env -i HOME=/var/lib/minetest \
    minetest-wrapper.sh \
    --world /var/lib/mercurio \
    --config /etc/minetest/minetest.conf
#!/bin/sh

set -e
world_dir=/root/.minetest/worlds/world

minetestserver --config /minetest.conf

echo "Checking generated zip file"

ls -lha ${world_dir}
test -f ${world_dir}/stage1.zip

hexdump -Cv ${world_dir}/stage1.zip
unzip -l ${world_dir}/stage1.zip

unzip ${world_dir}/stage1.zip

test -f test.txt
contents=$(cat test.txt)
test "${contents}" == "abcdefghijklmnopqrstuvwxyz"
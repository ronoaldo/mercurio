#!/bin/bash
set -e
set -o pipefail

export WORLD=$HOME/.minetest/worlds/minenews-dev
export LOGS=$(mktemp "$WORLD/debug.txt")

rm -rvf $WORLD
mkdir -p $WORLD/worldmods
cp -r scripts/world/* $WORLD/
cp -r ./ $WORLD/worldmods/minenews

if [ x"$1" = x"pt" ]; then
    echo -e '\nlanguage = pt_BR' >> $WORLD/minetest.conf
fi

exec minetest --verbose --config $WORLD/minetest.conf --world $WORLD --go
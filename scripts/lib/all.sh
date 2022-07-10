#!/bin/bash

LIB_DIR=${BASH_SOURCE:-$0}
LIB_DIR="$(dirname "$LIB_DIR")"
LIB_DIR="$(readlink -f "$LIB_DIR")"

source ${LIB_DIR}/discord.sh
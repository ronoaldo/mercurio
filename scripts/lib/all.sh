#!/bin/bash

# Globals
LIB_DIR=${BASH_SOURCE:-$0}
LIB_DIR="$(dirname "$LIB_DIR")"
LIB_DIR="$(readlink -f "$LIB_DIR")"

# Helper libraries
source ${LIB_DIR}/discord.sh

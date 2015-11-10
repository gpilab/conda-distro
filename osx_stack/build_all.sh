#!/bin/bash

set -e

# Make sure root is running this script.
if [ "$(id -u)" != "0" ]; then
    echo "You must be a root user to build." 2>&1
    echo "build aborted."
    exit 1
fi

NAME=$1

function buildall ()
{
    ./wrappaconda.sh $NAME
    ./build_dmg.sh $NAME
}

time buildall

echo "Done"

#!/bin/bash

# Make sure root is running this script.
if [ "$(id -u)" != "0" ]; then
    echo "You must be a root user to build." 2>&1
    echo "build aborted."
    exit 1
fi

function buildall ()
{
    ./build_stack.sh /opt/gpi
    ./build_makeself.sh
}

time buildall

echo "Done"

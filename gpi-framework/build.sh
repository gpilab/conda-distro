#!/bin/bash
# Check the OS b/c of differences in 'cp' (BSD vs GNU).

# OSX
if [ "$(uname)" == "Darwin" ]; then
    cp -R bin/ $PREFIX/bin/
    cp -R lib/ $SP_DIR
    cp -R include/ $PREFIX/include/
    cp launch/gpi.command $PREFIX/bin/gpi_app
fi

# Linux
if [ "$(uname)" == "Linux" ]; then
    cp -R bin/* $PREFIX/bin/
    cp -R lib/gpi $SP_DIR
    cp -R include/* $PREFIX/include/
fi

# copy and rename 'gpi.command' to 'gpi'
cp launch/gpi.command $PREFIX/bin/gpi

# copy licenses to lib dir
cp LICENSE $SP_DIR/gpi/
cp COPYING $SP_DIR/gpi/
cp COPYING.LESSER $SP_DIR/gpi/
cp AUTHORS $SP_DIR/gpi/

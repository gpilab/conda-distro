#!/bin/bash
# Check the OS b/c of differences in 'cp' (BSD vs GNU).

# OSX
if [ "$(uname)" == "Darwin" ]; then
    cp -R bin/ $PREFIX/bin/
    cp -R lib/ $PREFIX/lib/
    cp -R include/ $PREFIX/include/
fi

# Linux
if [ "$(uname)" == "Linux" ]; then
    cp -R bin/* $PREFIX/bin/
    cp -R lib/gpi $PREFIX/lib/
    cp -R include/* $PREFIX/include/
fi

# copy and rename 'gpi.command' to 'gpi'
cp launch/gpi.command $PREFIX/bin/gpi

# copy licenses to lib dir
cp LICENSE $PREFIX/lib/gpi/
cp COPYING $PREFIX/lib/gpi/
cp COPYING.LESSER $PREFIX/lib/gpi/
cp AUTHORS $PREFIX/lib/gpi/

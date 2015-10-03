#!/bin/sh

# OSX
if [ "$(uname)" == "Darwin" ]; then
    cd build/mac
fi

# Linux
if [ "$(uname)" == "Linux" ]; then
    cd build/gcc
fi

make && make prefix=$PREFIX install

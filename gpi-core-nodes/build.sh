#!/bin/sh

which gpi_make
gpi_make --all
mkdir -p $PREFIX/lib/gpi/node-libs/core
cp -R * $PREFIX/lib/gpi/node-libs/core


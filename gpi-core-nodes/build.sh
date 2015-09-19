#!/bin/bash

set -x 
set -e

TGT_NODE_LIB=core
UNIQUE_DIR=__build # this dir shouldn't exist in the repo

# make a unique directory to hold the node-lib for building
mkdir -p ./$UNIQUE_DIR/$TGT_NODE_LIB

# copy lic files for conda to grab at the end of the build
cp LICENSE ./$UNIQUE_DIR/

# copy everything to a unique directory b/c c-code is linked based on lib-name
shopt -s extglob
mv !($UNIQUE_DIR) ./$UNIQUE_DIR/$TGT_NODE_LIB/

# make the binaries
cd $UNIQUE_DIR
which gpi_make
gpi_make --all --ignore-gpirc -r3

# install under the gpi package
mkdir -p $PREFIX/lib/gpi/node-libs
cp -r $TGT_NODE_LIB $PREFIX/lib/gpi/node-libs/

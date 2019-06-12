#!/bin/bash
TGT_NODE_LIB=core
UNIQUE_DIR=__build # this dir shouldn't exist in the repo

# make a unique directory to hold the node-lib for building
mkdir -p ./$UNIQUE_DIR/$TGT_NODE_LIB

# copy lic files for conda to grab at the end of the build
# cp LICENSE ./$UNIQUE_DIR/
# cp COPYING ./$UNIQUE_DIR/
# cp COPYING.LESSER ./$UNIQUE_DIR/
# cp AUTHORS ./$UNIQUE_DIR/

# copy everything to a unique directory b/c c-code is linked based on lib-name
shopt -s extglob
mv !($UNIQUE_DIR) ./$UNIQUE_DIR/$TGT_NODE_LIB/

# make the binaries
cd $UNIQUE_DIR
# rm core/spiral/spiral_PyMOD.cpp
gpi_make --all --ignore-gpirc -r 3

# install under the gpi package
mkdir -p $SP_DIR/gpi/node-libs
cp -r $TGT_NODE_LIB $SP_DIR/gpi/node-libs/

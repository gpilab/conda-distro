#!/bin/bash

set -x 
set -e

mkdir -p ./__build/core

cp LICENSE ./__build/

shopt -s extglob
mv !(__build) ./__build/core/

cd __build

which gpi_make
gpi_make --all --ignore-gpirc -r3

mkdir -p $PREFIX/lib/gpi/node-libs
cp -r core $PREFIX/lib/gpi/node-libs/

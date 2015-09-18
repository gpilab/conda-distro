#!/bin/bash

set -x
set -e

cp -R bin $PREFIX/bin
cp -R lib $PREFIX/lib
cp -R include $PREFIX/include
cp -R launch/gpi.command $PREFIX/bin/gpi

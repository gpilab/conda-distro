#!/bin/bash

set -x 
set -e

# install under the gpi package
mkdir -p $PREFIX/lib/gpi/doc
cp -r * $TGT_NODE_LIB $PREFIX/lib/gpi/doc/

#!/bin/bash
USER=gpi
CHANNEL=main
CONDA_PY=35
PKG_BUILDNUM=0

export CONDA_PY
export PKG_BUILDNUM

OUTPUT=`conda build ./ --output`
echo "OUTPUT" $OUTPUT
conda build ./
anaconda upload -u $USER -c $CHANNEL $OUTPUT --force

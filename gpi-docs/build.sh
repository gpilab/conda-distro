#!/bin/bash

set -x 
set -e

DOCS_DIR=$PREFIX/share/doc/gpi

mkdir -p $DOCS_DIR
cp -r * ${DOCS_DIR}/

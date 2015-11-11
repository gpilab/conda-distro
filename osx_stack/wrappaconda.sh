#!/bin/bash
NAME=$1 # could be GPI or GPI_TEST, etc...
TARGET_BINARY=gpi.app
GPI_VERSION="1.0.0-rc"
CHANNEL=https://conda.anaconda.org/gpi/channel/rc
PACKAGES="gpi,gpi-core-nodes,gpi-docs"
PYTHON_VERSION=3.5
APP_ICON=gpi.icns

WRAPPACONDA=wrappaconda
$WRAPPACONDA -n $NAME -t $TARGET_BINARY -v $GPI_VERSION -i $APP_ICON \
             -c $CHANNEL -p $PACKAGES -o --py $PYTHON_VERSION

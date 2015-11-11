#!/bin/bash

# APP/Bundle
NAME=$1 # could be GPI or GPI_TEST, etc... results in <NAME>.app
TARGET_BINARY=gpi.app # what the bundle.app runs
GPI_VERSION="dev" # for the bundle.app (not sure where it gets reported)

# Conda
CHANNEL=https://conda.anaconda.org/gpi/channel/rc
#CHANNEL=main
PACKAGES="gpi,gpi-core-nodes,gpi-docs"
PYTHON_VERSION=3.5
APP_ICON=gpi.icns

WRAPPACONDA=wrappaconda
$WRAPPACONDA -n $NAME -t $TARGET_BINARY -v $GPI_VERSION -i $APP_ICON \
             -c $CHANNEL -p $PACKAGES -o --py $PYTHON_VERSION

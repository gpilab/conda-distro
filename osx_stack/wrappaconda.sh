#!/bin/bash

# APP/Bundle
NAME=$1 # could be GPI or GPI_TEST, etc... results in <NAME>.app
TARGET_BINARY=gpi.app # what the bundle.app runs
# GPI_VERSION is for the bundle.app (reported in Finder.app)
# Its set to 'check about page' since the app shell doesn't get replaced in
# updates. -it might be possible to get a new info.plist from conda.
GPI_VERSION="Check_About_Page" 


# Conda
CHANNEL=https://conda.anaconda.org/gpi/channel/rc
#CHANNEL=main
PACKAGES="gpi,gpi-core-nodes,gpi-docs"
PYTHON_VERSION=3.5
APP_ICON=gpi.icns

WRAPPACONDA=wrappaconda
$WRAPPACONDA -n $NAME -t $TARGET_BINARY -v $GPI_VERSION -i $APP_ICON \
             -c $CHANNEL -p $PACKAGES -o --py $PYTHON_VERSION

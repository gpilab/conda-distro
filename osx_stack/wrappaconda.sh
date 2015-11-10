#!/bin/bash
NAME=$1
GPI_VERSION="1.0.0-rc"
WRAPPACONDA=wrappaconda
$WRAPPACONDA -n $NAME -t gpi.app -v $GPI_VERSION -i gpi.icns -c https://conda.anaconda.org/gpi/channel/rc -p gpi,gpi-core-nodes,gpi-docs -o

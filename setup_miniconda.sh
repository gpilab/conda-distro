#!/bin/bash
# This script is for quickly installing the latest miniconda (python3).

# OSX
if [ "$(uname)" == "Darwin" ]; then
    wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
    chmod a+x Miniconda3-latest-MacOSX-x86_64.sh
    ./Miniconda3-latest-MacOSX-x86_64.sh
fi

# Linux
if [ "$(uname)" == "Linux" ]; then
    wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod a+x Miniconda3-latest-Linux-x86_64.sh
    ./Miniconda3-latest-Linux-x86_64.sh
fi

#!/bin/bash
# build the GPI-MiniConda Stack (python3).

MINICONDA_PATH=$1 # conda install location
CONDA=$MINICONDA_PATH/bin/conda

# Make sure root is running this script.
#   root is needed for:
#       -modifying the /Applications directory
#       -ensuring all ownership as root when the package is done
#if [ "$(id -u)" != "0" ]; then
#    echo "You must be a root user to modify the $DEST directory" 2>&1
#    echo "build aborted."
#    exit 1
#fi

# See if the Stack is already installed.
if [ -d "$MINICONDA_PATH" ]; then
    echo "Removing currently installed MiniConda..."
    rm -rf $MINICONDA_PATH
fi

# Install MiniConda
echo "Downloading and Installing MiniConda..."
./install_miniconda.sh $MINICONDA_PATH

# Install Conda Packages
echo "Installing GPI and the root packages..."
$CONDA install -y -c gpi --file ./rootenv.txt

echo "Removing package files..."
$CONDA clean -t -i -p -l -y 

# This is a bug in the current scipy/py35 release.
#   -Not sure if this fixes it, but it seems to get rid of the errors.
echo "Linking libgfortran.so.3 -> libgfortran.so.1..."
ln -s $MINICONDA_PATH/lib/libgfortran.so.1 $MINICONDA_PATH/lib/libgfortran.so.3

echo "Done building the stack."

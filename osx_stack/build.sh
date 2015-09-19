#!/bin/bash
# build the GPI.app with miniconda (python3).

REF=./GPI.app # location and name of the app skeleton
TARGET=GPI.app # target name
DEST=/Applications # destination of the app
MINICONDA_PATH=$DEST/$TARGET/Contents/Resources/anaconda # conda install location
CONDA=$MINICONDA_PATH/bin/conda

# Make sure root is running this script.
#   root is needed for:
#       -modifying the /Applications directory
#       -ensuring all ownership as root when the package is done
if [ "$(id -u)" != "0" ]; then
    echo "You must be a root user to modify the $DEST directory" 2>&1
    echo "build aborted."
    exit 1
fi

# See if the GPI.app is already installed.
if [ -d "$DEST/$TARGET" ]; then
    echo "Removing currently installed GPI.app..."
    rm -rf $DEST/$TARGET
fi

# Copy the GPI.app shell to 'Applications'.
echo "Copying $REF to $DEST ..."
cp -r $REF $DEST/

# Install MiniConda
echo "Downloading and Installing MiniConda..."
./install_miniconda.sh $MINICONDA_PATH

# install gpi
echo "Installing GPI and dependencies..."
$CONDA install -y -c gpi gpi
echo "Removing package files..."
$CONDA clean -t -i -p -l -y 

echo "Done."

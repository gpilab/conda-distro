#!/bin/bash
# Build the GPI-MiniConda Stack (python3).

MINICONDA_PATH=$1 # conda install location
CONDA=$MINICONDA_PATH/bin/conda

# help
if [ -n "$MINICONDA_PATH" ]; then
    echo "Installing into $MINICONDA_PATH"
else
    echo "usage: $0 <path>"
    echo " "
    echo "    Example: $0 ~/gpi_stack"
    echo " "
    exit 1
fi

install ()
{
    # See if the directory is already in use
    if [ -d "$MINICONDA_PATH" ]; then
        echo "The supplied directory already exists, installation aborted."
        exit 1
    fi

    # Install MiniConda
    echo "Downloading and Installing MiniConda..."
    # OSX
    if [ "$(uname)" == "Darwin" ]; then
        wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
        chmod a+x Miniconda3-latest-MacOSX-x86_64.sh
        ./Miniconda3-latest-MacOSX-x86_64.sh -b -p $MINICONDA_PATH
    fi
    # Linux
    if [ "$(uname)" == "Linux" ]; then
        wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
        chmod a+x Miniconda3-latest-Linux-x86_64.sh
        ./Miniconda3-latest-Linux-x86_64.sh -b -p $MINICONDA_PATH
    fi

    # Install Conda Packages
    echo "Installing the GPI packages..."
    $CONDA install -y -c gpi python=3.5 gpi gpi-docs gpi-core-nodes

    # Linux
    if [ "$(uname)" == "Linux" ]; then
        $CONDA install -y libgfortran=1.0

        # This is a bug in the current scipy/py35 release.
        #   -Not sure if this fixes it, but it seems to get rid of the errors.
        echo "Linking libgfortran.so.3 -> libgfortran.so.1..."
        ln -s $MINICONDA_PATH/lib/libgfortran.so.1 $MINICONDA_PATH/lib/libgfortran.so.3
    fi

    echo "Removing package files..."
    $CONDA clean -t -i -p -l -y 

    # Clean up the downloaded files
    echo "Removing tmp files..."
    # OSX
    if [ "$(uname)" == "Darwin" ]; then
        rm ./Miniconda3-latest-MacOSX-x86_64.sh
    fi
    # Linux
    if [ "$(uname)" == "Linux" ]; then
        rm ./Miniconda3-latest-Linux-x86_64.sh
    fi
}

# Run the installer
install

echo "Done."
echo " "
echo "------------------------------------------------------------------------"
echo "To start GPI enter:"
echo " "
echo "    \$ $MINICONDA_PATH/bin/gpi"
echo " "
echo "To add GPI (and this Anaconda install) to your PATH, add the following"
echo "line to your .bashrc file:"
echo " "
echo "PATH=\"$MINICONDA_PATH/bin:\$PATH\""
echo " "
echo " "
exit

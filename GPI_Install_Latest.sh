#!/bin/bash
# Build the GPI-MiniConda Stack for python 3 (or 2).

# default options
PYTHON_VER=3.5
MINICONDA_NAME=Miniconda3
CHANNEL=gpi

help ()
{
    echo " "
    echo "      --------------------------------------------------------      "
    echo " "
    echo "  Welcome to the GPI-MiniConda stack installer.  This script will   "
    echo "     install MiniConda (continuum.io) and the GPI (gpilab.com)      "
    echo "            application packages to a given directory.              "
    echo " "
    echo "                         - - - - - - - - -                          "
    echo " "
    echo "usage: $0 [options] [path]"
    echo "    -3    install the python 3.5 stack (default)"
    echo "    -2    install the python 2.7 stack"
    echo "    -h    this help"
    echo " "
    echo "    Example: $0 ~/gpi_stack"
    echo " "
    exit 1
}

# user options
while getopts "h32c:" opt; do
  case $opt in
    3)
      PYTHON_VER=3.5
      MINICONDA_NAME=Miniconda3
      ;;
    2)
      echo "The python 2 stack is deprecated, consider moving to python 3." >&2
      PYTHON_VER=2.7
      MINICONDA_NAME=Miniconda
      ;;
    c)
      CHANNEL=$OPTARG
      echo "Using channel $CHANNEL ." >&2 
      ;;
    h)
      help >&2
      ;;
  esac
done

# check for available commands
if command -v wget >/dev/null 2>&1; then
    GET="wget -c "
elif command -v curl >/dev/null 2>&1; then
    GET="curl -O -C - "
else
    echo "This script requires either wget or curl, aborting."
    exit 1
fi

# check for root
if [ "$(id -u)" == "0" ]; then
    echo -n " 
    It looks like you are attempting to install GPI as root or sudo. While
    this is possible, it is recommended that you install GPI under your 
    home directory.

    Press ENTER to continue or CTRL-c to quit.
    "
    read dummy
fi

# get user path
shift $(($OPTIND - 1))
MINICONDA_PATH=$1 # conda install location
CONDA=$MINICONDA_PATH/bin/conda
if [ -z "$MINICONDA_PATH" ]; then
    help
fi
PATHTOTHEPATH=`dirname $MINICONDA_PATH`
if [ ! -d "$PATHTOTHEPATH" ]; then
    echo "The parent path '$PATHTOTHEPATH' doesn't exit."
    exit 1
fi
if [[ ! "$MINICONDA_PATH" = /* ]]; then
    echo "Please provide a full path ('~' is allowed)."
    exit 1
fi
# See if the directory is already in use
if [ -d "$MINICONDA_PATH" ]; then
    echo "The supplied directory already exists, installation aborted."
    exit 1
fi
echo "Installing the GPI stack for python $PYTHON_VER in $MINICONDA_PATH ..."

# Install MiniConda -detect OS
echo "Downloading and Installing MiniConda..."
MINICONDA_WEB=https://repo.continuum.io/miniconda/
MINICONDA_OSX=$MINICONDA_NAME-latest-MacOSX-x86_64.sh
MINICONDA_LINUX=$MINICONDA_NAME-latest-Linux-x86_64.sh
# OSX
if [ "$(uname)" == "Darwin" ]; then
    MINICONDA_SCRIPT=$MINICONDA_OSX
fi
# Linux
if [ "$(uname)" == "Linux" ]; then
    MINICONDA_SCRIPT=$MINICONDA_LINUX
fi

install ()
{
    # make a tmp working dir
    TMPDIR=`mktemp -d`
    cd $TMPDIR

    # Run install script
    $GET $MINICONDA_WEB/$MINICONDA_SCRIPT
    chmod a+x $MINICONDA_SCRIPT
    ./$MINICONDA_SCRIPT -b -p $MINICONDA_PATH

    # Install Conda Packages
    echo "Installing the GPI packages..."
    $CONDA install -y -c $CHANNEL python=$PYTHON_VER gpi gpi-docs gpi-core-nodes

    # Linux
    if [ "$(uname)" == "Linux" ]; then
        if [ "$PYTHON_VER" == "3.5" ]; then
            $CONDA install -y libgfortran=1.0

            # This is a bug in the current scipy/py35 release.
            #   -Not sure if this fixes it, but it seems to get rid of the errors.
            echo "Linking libgfortran.so.3 -> libgfortran.so.1..."
            ln -s $MINICONDA_PATH/lib/libgfortran.so.1 $MINICONDA_PATH/lib/libgfortran.so.3
        fi
    fi

    echo "Removing package files..."
    $CONDA clean -t -i -p -l -y 

    # Clean up the downloaded files
    echo "Removing tmp files..."
    cd -
    rm -rf $TMPDIR
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

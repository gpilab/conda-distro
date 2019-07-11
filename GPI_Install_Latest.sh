#!/bin/bash
# Build the GPI-MiniConda Stack for python 3 (or 2).

# default options
PYTHON_VER=3
MINICONDA_NAME=Miniconda3

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
    echo "    -3    install the python 3.7 stack (default)"
    echo "    -h    this help"
    echo " "
    echo "    Example: $0 ~/gpi_stack"
    echo " "
    echo "Alternatively, if you already have the conda package manager from a"
    echo "previous Anaconda or Miniconda installation, you can install GPI"
    echo "into a Python 3.6+ environment with the following commands:"
    echo " "
    echo "    ~$ conda create -n gpi python=3.x"
    echo "    ~$ conda activate gpi"
    echo "    ~$ conda install -c conda-forge --strict-channel-priority gpi gpi_core"
    echo " "
    echo "Note that the --strict-channel-priority flag is not always required,"
    echo "but is now recommended in the conda-forge ecosystem. You can add    "
    echo "conda-forge and make strict priority the default by running:
    echo " "
    echo "    -$ conda config --add channels conda-forge:"
    echo "    -$ conda config --set channel_priority strict"
    echo "For more details see:"
    echo "    https://conda-forge.org/docs/user/tipsandtricks.html"
    exit 1
}

# user options
while getopts "h32c:" opt; do
  case $opt in
    3)
      PYTHON_VER=3
      MINICONDA_NAME=Miniconda3
      ;;
    2)
      echo "Sorry, the Python 2 GPI stack and installation is deprecated."
      echo "Consider moving to Python 3 for GPI development." >&2
      exit
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
MINICONDA_WEB=https://repo.continuum.io/miniconda
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

    . $MINICONDA_PATH/etc/profile.d/conda.sh
    conda create -n gpi -y
    conda activate gpi

    # add conda-forge channel
    # priority: conda-forge > defaults
    conda config --add channels conda-forge
    # Set channel priority to strict per conda-forge recommendation
    conda config --set channel_priority strict

    # Install Conda Packages
    # 1. First install the python version.
    #   -this is needed to select the right one before gpi deps are determined
    # 2. Install gpi with no-deps to ensure the latest is picked.
    # 3. Update and install all deps.
    echo "Installing the GPI packages..."
    # get a base intall of python
    # $CONDA install -y python
    $CONDA install -y gpi gpi_core

    echo "Removing package files..."
    $CONDA clean -t -i -p -l -y

    # Clean up the downloaded files
    echo "Removing tmp files..."
    cd ~
    rm -rf $TMPDIR
}

# Run the installer
install

if [ -e $MINICONDA_PATH/envs/gpi/bin/gpi ]
then
    echo " ------------------------------------"
    echo "|  GPI installation was successful!  |"
    echo " ------------------------------------"
    echo " "
    echo "To start GPI enter:"
    echo " "
    echo "    \$ conda activate gpi"
    echo "    \$ gpi"
    echo " "
    echo "Run 'conda init' to enable 'conda activate' in your shell."
    echo "Would you like to do this now?"
    read -p "Would you like to do this now? [Y/n]" -n 1 -r CONDA_INIT
    echo
    CONDA_INIT=${CONDA_INIT:-Y}
    if [[ $CONDA_INIT =~ ^[Yy]$ ]]
    then
        # echo ". $MINICONDA_PATH/etc/profile.d/conda.sh" >> ~/.bashrc
        $MINICONDA_PATH/condabin/conda init
        echo "Launch a new terminal for this to take effect."
    fi
    echo " "
else
    echo " ----------------------------"
    echo "|  GPI installation FAILED!  |"
    echo " ----------------------------"
    echo "removing $MINICONDA_PATH"
    rm -rf $MINICONDA_PATH
    echo " "
    echo "Please try running the script again."
    echo " "
    echo "Scroll up to see if you can spot the error."
    echo "If you still have issues, copy the output of the"
    echo "installation command and report issues on the"
    echo "GitHub issue tracker:"
    echo "https://github.com/gpilab/conda-distro/issues"
fi

exit

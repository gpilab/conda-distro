#!/bin/bash
# Build the GPI-MiniConda Stack for python 3 (or 2).

# default options
PYTHON_VER=3.7
QT_VER=5.9
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
    echo "    -p             specify python version (3.6 or 3.7 - default is 3.7)"
    echo "    -q             specify qt version (5.6 or 5.9 - default is 5.9)"
    echo "    -c <channel>   specify a different anaconda channel"
    echo "                     (for, e.g., testing custom builds)"
    echo "    -h             display this help"
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
    echo "but is now recommended in the conda-forge ecosystem (and will be the"
    echo "default if this script installs miniconda for you). You can add    "
    echo "conda-forge and set strict priority for an existing install with:        "
    echo " "
    echo "    -$ conda config --add channels conda-forge:"
    echo "    -$ conda config --set channel_priority strict"
    echo " "
    echo "For more details see:"
    echo "    https://conda-forge.org/docs/user/tipsandtricks.html"
    exit 1
}

# user options
while getopts ":p:q:c:h:" opt; do
  case $opt in
    p)
      PYTHON_VER=$OPTARG
      if [ $PYTHON_VER != "3.6" ] && [ $PYTHON_VER != "3.7" ]
      then
        echo $PYTHON_VER
        echo "Invalid python version passed. You specified $PYTHON_VER."
        echo " Valid choices are 3.6 and 3.7."
        exit 1
      fi
      ;;
    q)
      QT_VER=$OPTARG
      if [ $QT_VER != "5.6" ] && [ $QT_VER != "5.9" ]
      then
        echo "Invalid Qt version passed. You specified $QT_VER."
        echo " Valid choices are 5.6 and 5.9."
        exit 1
      fi
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

# Parse the OS
if [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    OS=0 #Windows
elif [ "$(uname)" == "Darwin" ]; then
    OS=1 #Mac OSX
elif [ "$(uname)" == "Linux" ]; then
    OS=2 #Linux
else
    OS=-1 #Invalid
fi

# Prompt for an extra dependency if running Ubuntu within WSL
if [ $OS == 2 ]; then
    if grep -q Microsoft /proc/version; then
        NEEDED_PKGS="python3-pyqt5.qtwebkit build-essential ca-certificates libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6"
        for pkg in $NEEDED_PKGS
        do
            dpkg -s $pkg > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "GPI requires extra packages to run on WSL + Ubuntu"
	        echo "A required package ($pkg) was not found, and others may be missing."
        	echo "Please run the following command, then re-run this script:"
	        echo "sudo apt-get install $NEEDED_PKGS"
	        exit 1
            fi
        done
    fi
fi

# Miniconda version is always 3 now.
MINICONDA_NAME=Miniconda3

# check for available commands
if command -v wget >/dev/null 2>&1; then
    GET="wget -c "
elif command -v curl >/dev/null 2>&1; then
    GET="curl -O -C - "
else
    echo "This script requires either wget or curl."
    echo "Please install one of these with yum, apt-get, etc., then re-run this script."
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
case "$OS" in
0) 
    MINICONDA_PATH_WIN=$(CYGPATH -w $MINICONDA_PATH)
    CONDA=$MINICONDA_PATH\\Scripts\\conda.exe
    ;;
[1-2])
    CONDA=$MINICONDA_PATH/bin/conda
    ;;
esac

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
case "$OS" in
0)
    MINICONDA_SCRIPT=$MINICONDA_NAME-latest-Windows-x86_64.exe
    ;;
1)
    MINICONDA_SCRIPT=$MINICONDA_NAME-latest-MacOSX-x86_64.sh
    ;;
2)
    MINICONDA_SCRIPT=$MINICONDA_NAME-latest-Linux-x86_64.sh
    ;;
esac

install ()
{
    
    # make a tmp working dir
    TMPDIR=`mktemp -d`
    cd $TMPDIR

    # Run install script
    $GET $MINICONDA_WEB/$MINICONDA_SCRIPT
    chmod a+x $MINICONDA_SCRIPT

    case "$OS" in
    0)
	./$MINICONDA_SCRIPT //S "/D=$MINICONDA_PATH_WIN"
	;;
    [1-2])
        ./$MINICONDA_SCRIPT -b -p $MINICONDA_PATH
	;;
    esac

    . $MINICONDA_PATH/etc/profile.d/conda.sh

    # add conda-forge channel
    # priority: conda-forge > defaults
    $CONDA config --add channels danielborup conda-forge
    # Set channel priority to strict per conda-forge recommendation
    $CONDA config --set channel_priority strict

    # Create the new env with gpi, allowing python and pyqt to be set explicitly
    case "$OS" in
    0)
	$CONDA create -n gpi -y python=$PYTHON_VER pyqt=$QT_VER gpi=1.1.6=py_1
	;;
    [1-2])
        $CONDA create -n gpi -y python=$PYTHON_VER pyqt=$QT_VER gpi_core
	$CONDA activate gpi
	;;
    esac

    echo "Removing package files..."
    $CONDA clean -t -i -p -l -y

    # Clean up the downloaded files
    echo "Removing tmp files..."
    cd ~
    rm -rf $TMPDIR
}

# Run the installer
install
#
if [ -e $MINICONDA_PATH/envs/gpi/bin/gpi ] || [ $OS == 0 ]; then
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
    read -p "Would you like to do this now? [Y/n]" -n 1 -r CONDA_INIT
    echo
    CONDA_INIT=${CONDA_INIT:-Y}
    if [[ $CONDA_INIT =~ ^[Yy]$ ]]
    then
	if [ $OS == 0 ]; then
	    $MINICONDA_PATH/Scripts/conda.exe init bash
        else
            $MINICONDA_PATH/condabin/conda init
	fi
        # echo ". $MINICONDA_PATH/etc/profile.d/conda.sh" >> ~/.bashrc
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

#!/bin/bash

# Miniconda version is always 3 now.
MINICONDA_NAME=Miniconda3

if [ "$(uname)" == "Darwin" ]; then
    OS=0 #Mac OSX
elif [ "$(uname)" == "Linux" ]; then
    OS=1 #Linux
else
    echo "This installer only runs on Mac OS or Linux. Aborting"
    exit 1
fi

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

# get user path
shift $(($OPTIND - 1))
MINICONDA_PATH=$1 # conda install location
CONDA=$MINICONDA_PATH/bin/conda
# windows CONDA="./gpi_stack/scripts/conda.exe"

if [ -z "$MINICONDA_PATH" ]; then
    echo "An installation path is required as an argument."
    echo "We recommend ~/gpi_stack, i.e., run the script again as follows:"
    echo "\$ ./GPI_Install_Clean.sh ~/gpi_stack"
    exit 1
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
echo "Downloading MiniConda..."
MINICONDA_WEB=https://repo.continuum.io/miniconda
case "$OS" in
0)
    MINICONDA_SCRIPT=$MINICONDA_NAME-latest-MacOSX-x86_64.sh
    ;;
1)
    MINICONDA_SCRIPT=$MINICONDA_NAME-latest-Linux-x86_64.sh
    ;;
esac

TMPDIR=`mktemp -d`
cd $TMPDIR

# Run install script
$GET $MINICONDA_WEB/$MINICONDA_SCRIPT
chmod a+x $MINICONDA_SCRIPT
echo " "
echo "Installing MiniConda. This may take a minute or two..."
./$MINICONDA_SCRIPT -b -p $MINICONDA_PATH

# . $MINICONDA_PATH/etc/profile.d/conda.sh

echo " "
echo "Installing GPI and the gpi_core nodes..."
$CONDA config --system --add channels conda-forge
$CONDA config --system --set --channel_priority strict
$CONDA create -y -n gpi
$CONDA install -y -n gpi gpi_core python=3.7 pyqt=5.9
echo "Removing package files..."
$CONDA clean -n gpi -tiply

# Clean up the downloaded files
echo "Removing tmp files..."
cd ..
rm -rf $TMPDIR

LAUNCH_FILE="$MINICONDA_PATH/envs/gpi/bin/gpi"
if [ -e $LAUNCH_FILE ]; then
    echo " ------------------------------------"
    echo "|  GPI installation was successful!  |"
    echo " ------------------------------------"
    echo " "
    echo "Creating launch script \"gpi_run\" on Desktop."
    GPI_DIR="$MINICONDA_PATH/envs/gpi/"
    GPI_RUNFILE="$HOME/Desktop/gpi_run.sh"

    echo '#!/bin/bash' > $GPI_RUNFILE
    echo '' >> $GPI_RUNFILE
    echo 'export PATH="' + ${GPI_DIR} + '/bin:${PATH}' >> $GPI_RUNFILE #always
#win echo 'export PATH="' + ${GPI_DIR} + '/Scripts:${PATH}'
#win echo 'export PATH="' + ${GPI_DIR} + '/Library/bin:${PATH}'
#win echo 'export PATH="' + ${GPI_DIR} + '/Library/usr/bin:${PATH}'
#win echo 'export PATH="' + ${GPI_DIR} + '/Library/mingw-w64/bin:${PATH}'
#win echo 'export PATH="' + ${GPI_DIR} + ':${PATH}'
    echo '' >> $GPI_RUNFILE
    echo 'gpi' >> $GPI_RUNFILE
    chmod a+x $GPI_RUNFILE
else
    echo " ----------------------------"
    echo "|  GPI installation FAILED!  |"
    echo " ----------------------------"
    echo "removing broken installation"
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

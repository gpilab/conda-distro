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
    echo "This script requires either wget or curl to download the latest files."
    echo "Linux users may need to install one of these with yum, apt-get, etc., then re-run this script."
    echo "MacOS should include curl by default."
    exit 1
fi

case "$OS" in
0)
  # MacOS - pre-create GPI.app folder in case we want to put Miniconda there
  GPI_APP="/Applications/GPI.app"
  CONTENTS="${GPI_APP}/Contents"
  mkdir -p ${CONTENTS}/MacOS
  mkdir ${CONTENTS}/Resources
  ;;
esac

if [ $# -eq 0 ]; then
  case "$OS" in
  0)
    echo "This script will install GPI into the Applications folder."
    MINICONDA_PATH="${CONTENTS}/gpi_stack"
    ;;
  1)
    echo "This script will install GPI into your home folder."
    MINICONDA_PATH="${HOME}/gpi_stack" # conda install location
    ;;
  esac
elif [ $# -eq 1 ]; then
  shift $(($OPTIND - 1))
  MINICONDA_PATH=$1 # conda install location
  echo "This script will install GPI into ${MINICONDA_PATH}."
else
  echo "This script requires either no arguments (to use the default install path)"
  echo "or one argument (for a user-specified install path)."
  echo "Aborting."
  exit 1
fi

PATHTOTHEPATH=`dirname $MINICONDA_PATH`
if [ ! -d "$PATHTOTHEPATH" ]; then
    echo "The directory '$PATHTOTHEPATH' doesn't exit."
    echo "This could mean you've moved your home folder (Linux) or Applications folder (Mac)."
    echo "Please re-run this script with an argument for the desired install location."
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

# Conda location
CONDA="${MINICONDA_PATH}/bin/conda"

echo "Installing support files..."
TMPDIR=`mktemp -d`
cd $TMPDIR

# Install MiniConda -detect OS
MINICONDA_WEB=https://repo.continuum.io/miniconda
case "$OS" in
0)
    MINICONDA_SCRIPT=$MINICONDA_NAME-latest-MacOSX-x86_64.sh
    ;;
1)
    MINICONDA_SCRIPT=$MINICONDA_NAME-latest-Linux-x86_64.sh
    ;;
esac

# Run install script
$GET $MINICONDA_WEB/$MINICONDA_SCRIPT
chmod a+x $MINICONDA_SCRIPT
./$MINICONDA_SCRIPT -b -p $MINICONDA_PATH

# . $MINICONDA_PATH/etc/profile.d/conda.sh

echo " "
echo "Installing GPI and the gpi_core nodes..."
$CONDA config --system --add channels conda-forge
$CONDA config --system --set channel_priority strict
$CONDA create -y -n gpi
$CONDA install -y -n gpi gpi_core conda python=3.7 pyqt=5.9

# Move conda config file inside environment for updating later 
CONFIGFILE="${MINICONDA_PATH}/.condarc"
GPI_ENV="${MINICONDA_PATH}/envs/gpi"
mv ${CONFIGFILE} ${GPI_ENV}

LAUNCH_FILE="$MINICONDA_PATH/envs/gpi/bin/gpi"
if [ -e $LAUNCH_FILE ]; then
    echo "Configuring application shortcut"
    GIT_BRANCH="clean_install"

  case "$OS" in
  0)
      GIT_URL="https://raw.githubusercontent.com/gpilab/conda-distro/${GIT_BRANCH}"
      $GET ${GIT_URL}/PkgInfo
      mv PkgInfo $CONTENTS
      
      VERFILE="${MINICONDA_PATH}/envs/gpi/lib/python3.7/site-packages/gpi/VERSION"
      VER=`sed -n -E 's/^.*([0-9]+\.[0-9]+\.[0-9]+)$/\1/p' $VERFILE`
      $GET ${GIT_URL}/Info.plist
      sed -i '.bak' "s/placehold_infostring_placehold_infostring/GPI v${VER}/g" Info.plist
      sed -i '.bak' "s/placehold_version/${VER}/g" Info.plist
      mv Info.plist $CONTENTS
      
      GPI_ICON="$MINICONDA_PATH/envs/gpi/lib/python3.7/site-packages/gpi/graphics/gpi.icns"
      cp ${GPI_ICON} ${CONTENTS}/Resources/app.icns
      
      LAUNCHER="${CONTENTS}/MacOS/gpi"
      echo "#!/bin/bash" > $LAUNCHER
      echo "" >> $LAUNCHER
      echo "open -a Terminal.app $LAUNCH_FILE" >> $LAUNCHER
      chmod a+x $LAUNCHER
      ;;
  1)
      GPI_ICON="$MINICONDA_PATH/envs/gpi/lib/python3.7/site-packages/gpi/graphics/iclogo.png"
      echo "Creating desktop shortcut..."
      DESKTOP_FILE="GPI.desktop"
      DESKTOP_URL="https://raw.githubusercontent.com/gpilab/conda-distro/${GIT_BRANCH}/${DESKTOP_FILE}"
      $GET $DESKTOP_URL
      sed -i "s+exec_placeholdplaceholdplaceholdplaceholdplacehold+${LAUNCH_FILE}+g" $DESKTOP_FILE
      sed -i "s+icon_placeholdplaceholdplaceholdplaceholdplacehold+${GPI_ICON}+g" $DESKTOP_FILE
      chmod a+x $DESKTOP_FILE
      mv ${DESKTOP_FILE} ${HOME}/Desktop
      ;;
  esac
  echo " ------------------------------------"
  echo "|  GPI installation was successful!  |"
  echo " ------------------------------------"
  echo " "
  echo "Cleaning up"
  $CONDA clean -tiply

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

# Clean up the downloaded files
echo "Removing tmp files..."
cd ..
rm -rf $TMPDIR

exit

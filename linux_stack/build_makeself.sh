#!/bin/bash
# Author: Nick Zwart
# Date: 2014feb21
# Brief: The command used on makeself.sh
# This will create a GPI Stack to be installed in /opt/gpi.

build()
{

# check for root access
if [ "$(id -u)" != "0" ]; then
    echo "You must be a root user to build." 2>&1
    echo "Install Aborted."
    exit 1
fi

set -e
set -x

# clean the stage directory
echo "removing /opt/gpi_stage..."
rm -rf /opt/gpi_stage

PKG=gpi # package/dir to copy out of prefix
#PKG=lib # test
TARGET=/opt/
#TARGET=/opt/gpi/ # test
STAGE_DIR=/opt/gpi_stage
NODE_LIBS=node
INC_DIR=include
MSG="GPI Stack Installer"
INSTALLER_FNAME="gpi_install.run"
POST_SCRIPT="./post.sh"
MAKESELF="./makeself-2.1.5/makeself.sh"
COMPRESSION_OPT="--gzip"

# move all contents to a staging dir
# for post script update and permissions change
mkdir -p $STAGE_DIR
cp -r $TARGET/$PKG $STAGE_DIR/

# update post install hook
cp -v $POST_SCRIPT $STAGE_DIR/


# ignore find errors
#set +e

# remove all SCM and packaging
#find $STAGE_DIR -type d -name ".svn" -exec rm -rfv {} \;
#find $STAGE_DIR -type d -name ".git" -exec rm -rfv {} \;
#find $STAGE_DIR -type f -name ".gitignore" -exec rm -v {} \;
#find $STAGE_DIR/$PKG/$NODE_LIBS -type d -name "build" -exec rm -rfv {} \;
#find $STAGE_DIR/$PKG/$INC_DIR -type d -name "build" -exec rm -rfv {} \;

#set -e

# update permissions
#chmod -R 755 $STAGE_DIR

# update owner
chown -R root:root $STAGE_DIR

# make it
$MAKESELF $COMPRESSION_OPT $STAGE_DIR $INSTALLER_FNAME "$MSG" $POST_SCRIPT

# remove stage
rm -rf $STAGE_DIR

}

time build

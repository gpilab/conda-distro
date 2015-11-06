#!/bin/bash
# Bundle the GPI.app in a dmg for distribution.
# git clone https://github.com/andreyvit/create-dmg.git

# Make sure root is running this script.
#   root is needed for:
#       -creating a disk image
#       -copying a root owned app from /Applications
if [ "$(id -u)" != "0" ]; then
    echo "You must be a root user to modify the $DEST directory" 2>&1
    echo "build aborted."
    exit 1
fi

VERSION="1.0.0_rc" # must be valid chars for disk volume name
YPOS=300
XPOS_GPI=300
XPOS_LNK=600

ICON_SIZE=128
WINDOW_SIZE="900 500" # same size as the background image
BKGND_IMG=./logo_bkgnd.png

NAME=$1
VOLUME_NAME=${NAME}_$VERSION
TARGET=${NAME}.app
TARGET_DIR=/Applications
OUTPUT_DMG=${NAME}_Stack_${VERSION}.dmg
TMP_DIR=./tmp

echo "VOLUME_NAME" $VOLUME_NAME
echo "TARGET" $TARGET
echo "TARGET_DIR" $TARGET_DIR
echo "OUTPUT_DMG" $OUTPUT_DMG
echo "TMP_DIR" $TMP_DIR

# clean tmp directory
if [ -d "$TMP_DIR" ]; then
    echo "Removing current tmp dir $TMP_DIR ..."
    rm -rf $TMP_DIR
fi
echo "Making tmp dir $TMP_DIR ..."
mkdir -p $TMP_DIR

# copy so that the Finder doesn't get its grubby mitts on the file while packaging.
echo "copy $TARGET to $TMP_DIR ..."
cp -R $TARGET_DIR/$TARGET $TMP_DIR/

# clean working directory
if [ -f "$OUTPUT_DMG" ]; then
    echo "Removing currently installed $OUTPUT_DMG ..."
    rm -rf $OUTPUT_DMG
fi

# bundle in dmg
# --volicon ./graphics/icons/gpi.icns 
./create-dmg/create-dmg --volname $VOLUME_NAME \
    --background $BKGND_IMG \
    --window-size $WINDOW_SIZE \
    --icon-size $ICON_SIZE \
    --icon $TARGET $XPOS_GPI $YPOS \
    --app-drop-link $XPOS_LNK $YPOS \
    $OUTPUT_DMG $TMP_DIR/$TARGET || { echo 'create-dmg failed' ; exit 1; }

# clean tmp directory
if [ -d "$TMP_DIR" ]; then
    echo "Removing current tmp dir $TMP_DIR ..."
    rm -rf $TMP_DIR
fi

echo "Finished building DMG: $OUTPUT_DMG"

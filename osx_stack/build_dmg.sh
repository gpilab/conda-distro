#!/bin/bash
# Bundle the GPI.app in a dmg for distribution.
# git clone https://github.com/andreyvit/create-dmg.git

VERSION="0.6.0"
YPOS=300
XPOS_GPI=300
XPOS_LNK=600

ICON_SIZE=128
WINDOW_SIZE="900 500" # same size as the background image
BKGND_IMG=./logo_bkgnd3.png

VOLUME_NAME=GPI_$VERSION
TARGET=GPI.app
TARGET_DIR=/Applications
OUTPUT_DMG=GPI.dmg

# bundle in dmg
# --volicon ./graphics/icons/gpi.icns 
./create-dmg/create-dmg --volname $VOLUME_NAME \
    --background $BKGND_IMG \
    --window-size $WINDOW_SIZE \
    --icon-size $ICON_SIZE \
    --icon $TARGET $XPOS_GPI $YPOS \
    --app-drop-link $XPOS_LNK $YPOS \
    $OUTPUT_DMG $TARGET_DIR/$TARGET

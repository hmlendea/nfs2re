#!/bin/bash

if [ ! -f "QFS2BMP.exe" ]; then
    echo "ERROR: QFS2BMP.exe not found! Please copy the tool into this directory"
    exit 1
fi

if [ ! -f "/usr/bin/wine" ]; then
    echo "ERROR: WINE not installed. Please install it in order to build the assets"
    exit 1
fi

if [ -d tmp ]; then
    rm -rf tmp
fi

mkdir tmp

SLIDES=$(find "./src/fedata/pc/art/slides" -name "*.png")

for SLIDE in $SLIDES ; do
    FILE=$(basename $SLIDE)
    NAME=${FILE%.*}

    BMP_PATH="./tmp/$NAME.bmp"
    QFS_PATH="./out/fedata/pc/slides/$NAME.qfs"

    if [ ! -d "./out/fedata/pc/slides" ]; then
        mkdir -p "./out/fedata/pc/slides"
    fi

    echo $BMP_PATH
    convert $SLIDE BMP3:"./tmp/$NAME.bmp"
    yes | wine QFS2BMP.exe -e $BMP_PATH $QFS_PATH
    rm $BMP_PATH
done

if [ -d tmp ]; then
    rm -rf tmp
fi


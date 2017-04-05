#!/bin/bash

SRCDIR="src"
OUTDIR="out"
TMPDIR=".tmp"

[ -d "$TMPDIR" ] || mkdir "$TMPDIR"
[ -d "$OUTDIR/tools" ] || mkdir -p "$OUTDIR/tools"
[ -d "$OUTDIR/fedata/pc/art/slides" ] || mkdir -p "$OUTDIR/fedata/pc/art/slides"

gcc src/tools/fshtool.c -o "$OUTDIR/tools/fshtool"

### BUILD THE SLIDES

SLIDES=$(find "$SRCDIR/fedata/pc/art/slides" -name "*.png")

for SLIDE in $SLIDES ; do
    FILE=$(basename $SLIDE)
    NAME=${FILE%.*}

    BMPDIR="$TMPDIR/fedata/pc/slides/$NAME"
    [ -d "$BMPDIR" ] || mkdir -p "$BMPDIR"

    cp "$SRCDIR/fedata/pc/art/slides/index.fsh" "$BMPDIR"

    echo ">> Building $SLIDE..."
    convert $SLIDE BMP3:"$BMPDIR/0000.BMP"
    yes | "$OUTDIR/tools/fshtool" "$BMPDIR/index.fsh" "./$OUTDIR/fedata/pc/art/slides/$NAME.qfs"
done

### BUILD FINISHED

[ ! -d "$TMPDIR" ] || rm -rf "$TMPDIR"

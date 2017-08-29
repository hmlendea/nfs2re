#!/bin/bash

SRCDIR="src"
OUTDIR="out"

[ -d "$OUTDIR/tools" ] || mkdir -p "$OUTDIR/tools"
[ -d "$OUTDIR/fedata/pc/art/slides" ] || mkdir -p "$OUTDIR/fedata/pc/art/slides"

gcc "src/tools/fshtool.c" -o "$OUTDIR/tools/fshtool"

function build_qfs {
    FSHTOOL="$OUTDIR/tools/fshtool"

    echo "Building $1.qfs ..."

    yes | "$FSHTOOL" "$SRCDIR/$1/index.fsh" "$OUTDIR/$1.qfs"
}

### BUILD THE SLIDES

SLIDES=$(find "$SRCDIR/fedata/pc/art/slides/" -type d -name "sld*")

for SLIDE in $SLIDES ; do
    FILE=$(basename $SLIDE)
    NAME=${FILE%.*}

    build_qfs "fedata/pc/art/slides/$NAME"
done

build_qfs "fedata/pc/art/title"

### BUILD FINISHED

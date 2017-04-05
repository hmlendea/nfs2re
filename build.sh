#!/bin/bash

SRCDIR="src"
OUTDIR="out"

[ -d "$OUTDIR/tools" ] || mkdir -p "$OUTDIR/tools"
[ -d "$OUTDIR/fedata/pc/art/slides" ] || mkdir -p "$OUTDIR/fedata/pc/art/slides"

gcc "src/tools/fshtool.c" -o "$OUTDIR/tools/fshtool"

### BUILD THE SLIDES

SLIDES=$(find "$SRCDIR/fedata/pc/art/slides/" -type d -name "sld*")

for SLIDE in $SLIDES ; do
    FILE=$(basename $SLIDE)
    NAME=${FILE%.*}

    echo ">> Building $SLIDE..."
    yes | "$OUTDIR/tools/fshtool" "$SRCDIR/fedata/pc/art/slides/$NAME/index.fsh" "$OUTDIR/fedata/pc/art/slides/$NAME.qfs"
done

### BUILD FINISHED

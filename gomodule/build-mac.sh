#!/bin/sh

PROJNAME=ld2rdf

ROOTDIR=$(realpath $(dirname $0))
DISTDIR=$ROOTDIR/dist/mac
TMPDIR=$ROOTDIR/tmp/mac

mkdir -p $TMPDIR $DISTDIR

CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 go build -o $TMPDIR/amd64.dylib -buildmode=c-shared -trimpath .
CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 go build -o $TMPDIR/arm64.dylib -buildmode=c-shared -trimpath .
mkdir -p $TMPDIR/include/amd64 $TMPDIR/include/arm64
mv $TMPDIR/amd64.h $TMPDIR/include/amd64/
mv $TMPDIR/arm64.h $TMPDIR/include/arm64/

# NOTE: -create-xcframework does not work...
# xcodebuild -create-xcframework \
#     -library $TMPDIR/amd64.dylib -headers $TMPDIR/include/amd64 \
#     -library $TMPDIR/arm64.dylib -headers $TMPDIR/include/arm64 \
#     -output $DISTDIR/JsonLd2Rdf.xcframework

lipo -create -output $DISTDIR/lib$PROJNAME.dylib $TMPDIR/amd64.dylib $TMPDIR/arm64.dylib

#!/bin/sh

ROOTDIR=$(cd $(dirname $0); pwd -P)
DISTDIR=$ROOTDIR/dist/windows/x86_64

rm -rf $DISTDIR 
mkdir -p \
    $DISTDIR \

export GOOS=windows
export CGO_ENABLED=1

GOARCH=amd64 CC=x86_64-w64-mingw32-gcc \
    go build -v -x -buildmode=c-shared -trimpath -o=$DISTDIR/libld2rdf.dll


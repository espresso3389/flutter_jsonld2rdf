#!/bin/sh

ROOTDIR=$(cd $(dirname $0); pwd -P)
DISTDIR=$ROOTDIR/../ios
TMPDIR=$ROOTDIR/tmp/ios

mkdir -p $DISTDIR $TMPDIR

SDK_MINVER=11.0
LIBNAME=libld2rdf.a

build_ios () {
    export IPHONEOS_DEPLOYMENT_TARGET=$SDK_MINVER
    export GOARCH=$1
    export IOS_OR_SIM=$2
    DIRSPEC=$3
    OUTDIR=$TMPDIR/$DIRSPEC
    INCLUDEDIR=$OUTDIR/include

    # NOTE: -D_EXTRA_TAG=XXX is important to identify cached result.
    CGO_ENABLED=1 CGO_CFLAGS="-fembed-bitcode -D_EXTRA_TAG=$GOARCH,$IOS_OR_SIM" CGO_LDFLAGS="-fembed-bitcode -fPIC" GOOS=ios CC=$ROOTDIR/clangwrap.sh go build -x -buildmode=c-archive -trimpath -tags=$GOARCH,$IOS_OR_SIM -o=$OUTDIR/$LIBNAME
    mkdir -p $INCLUDEDIR
    mv $OUTDIR/*.h $INCLUDEDIR/
}

build_ios arm64 ios arm64
build_ios amd64 sim amd64
build_ios arm64 sim arm64sim

# IMPORTANT: universal library for arm64/x86_64 simulator
lipo -create -output $TMPDIR/amd64/$LIBNAME $TMPDIR/amd64/$LIBNAME $TMPDIR/arm64sim/$LIBNAME

rm -rf $DISTDIR/GoJsonLd2Rdf.xcframework
xcodebuild -create-xcframework \
    -library $TMPDIR/arm64/$LIBNAME -headers $TMPDIR/arm64/include \
    -library $TMPDIR/amd64/$LIBNAME -headers $TMPDIR/amd64/include \
    -output $DISTDIR/GoJsonLd2Rdf.xcframework 


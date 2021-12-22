#!/bin/sh

ROOTDIR=$(realpath $(dirname $0))
DISTDIR=$ROOTDIR/../ios
TMPDIR=$ROOTDIR/tmp/ios

mkdir -p $DISTDIR $TMPDIR

SDK_MINVER=12.0
LIBNAME=libld2rdf.a

build_ios () {
    GOARCH=$1
    if [ "$GOARCH" == "arm64" ]; then
        SDK=iphoneos
        PLATFORM=ios
        CLANGARCH="arm64"
    else
        SDK=iphonesimulator
        PLATFORM=ios-simulator
        CLANGARCH="x86_64"
    fi

    SDK_PATH=$(xcrun --sdk $SDK --show-sdk-path)
    CLANG=$(xcrun --sdk $SDK --find clang)

    OUTDIR=$TMPDIR/$GOARCH
    INCLUDEDIR=$OUTDIR/include

    CGO_ENABLED=1 CGO_CFLAGS=-fembed-bitcode CGO_LDFLAGS=-fembed-bitcode GOOS=ios GOARCH=$GOARCH IPHONEOS_DEPLOYMENT_TARGET=$SDK_MINVER CC=$(go env GOROOT)/misc/ios/clangwrap.sh go build -x -buildmode=c-archive -trimpath -tags=ios -o=$OUTDIR/$LIBNAME
    mkdir -p $INCLUDEDIR
    mv $OUTDIR/*.h $INCLUDEDIR/
}

build_ios arm64
build_ios amd64
rm -rf $DISTDIR/GoJsonLd2Rdf.xcframework
xcodebuild -create-xcframework \
    -library $TMPDIR/amd64/$LIBNAME -headers $TMPDIR/amd64/include \
    -library $TMPDIR/arm64/$LIBNAME -headers $TMPDIR/arm64/include \
    -output $DISTDIR/GoJsonLd2Rdf.xcframework 

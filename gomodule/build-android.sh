#!/bin/sh

# Assumes Android Studio is installed on the standard path along with Android SDK/NDK
export ANDROID_HOME=~/Library/Android/sdk/
export ANDROID_NDK_HOME=~/Library/Android/sdk/ndk/$(ls $ANDROID_HOME/ndk | head -1)
export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jre/Contents/Home

ROOTDIR=$(realpath $(dirname $0))
NDK_DIR=$ROOTDIR/tmp/ndk-toolchain
DISTDIR=$ROOTDIR/../android/src/main
TMPDIR=$ROOTDIR/tmp/android

export PATH=$NDK_DIR/bin:$ANDROID_HOME/platform-tools:$PATH

rm -rf $DISTDIR/jniLibs $TMPDIR
mkdir -p \
    $DISTDIR \
    $NDK_DIR \
    $TMPDIR/armeabi-v7a \
    $TMPDIR/arm64-v8a \
    $TMPDIR/x86 \
    $TMPDIR/x86_64

ANDROID_SDK_VERSION=22
CLANG_SUFFIX=-linux-android$ANDROID_SDK_VERSION-clang

rm -rf $NDK_DIR
$ANDROID_NDK_HOME/build/tools/make-standalone-toolchain.sh --install-dir=$NDK_DIR

export GOOS=android
export CGO_ENABLED=1

GOARCH=arm CC=armv7a-linux-androideabi$ANDROID_SDK_VERSION-clang CXX=armv7a-linux-androideabi$ANDROID_SDK_VERSION-clang++ \
    go build -v -x -buildmode=c-shared -trimpath -o=$TMPDIR/armeabi-v7a/libld2rdf.so
GOARCH=arm64 CC=aarch64$CLANG_SUFFIX CXX=aarch64$CLANG_SUFFIX++ \
    go build -v -x -buildmode=c-shared -trimpath -o=$TMPDIR/arm64-v8a/libld2rdf.so
GOARCH=386 CC=i686$CLANG_SUFFIX CXX=i686$CLANG_SUFFIX++ \
    go build -v -x -buildmode=c-shared -trimpath -o=$TMPDIR/x86/libld2rdf.so
GOARCH=amd64 CC=x86_64$CLANG_SUFFIX CXX=x86_64$CLANG_SUFFIX++ \
    go build -v -x -buildmode=c-shared -trimpath -o=$TMPDIR/x86_64/libld2rdf.so

cp -rf $TMPDIR $DISTDIR/jniLibs
find $DISTDIR -name "*.h" -exec rm {} \;
rm -rf $DISTDIR/jniLibs/tmp

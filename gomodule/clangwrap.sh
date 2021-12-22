#!/bin/sh
# This uses the latest available iOS SDK, which is recommended.
# To select a specific SDK, run 'xcodebuild -showsdks'
# to see the available SDKs and replace iphoneos with one of them.
if [ "$GOARCH" == "arm64" ]; then
	CLANGARCH="arm64"
else
	CLANGARCH="x86_64"
fi

if [ "$IOS_OR_SIM" == "ios" ]; then
	SDK=iphoneos
	PLATFORM=ios
else
	SDK=iphonesimulator
	PLATFORM=ios-simulator
fi

SDK_PATH=`xcrun --sdk $SDK --show-sdk-path`
# cmd/cgo doesn't support llvm-gcc-4.2, so we have to use clang.
CLANG=`xcrun --sdk $SDK --find clang`

exec "$CLANG" -arch $CLANGARCH -isysroot "$SDK_PATH" -m${PLATFORM}-version-min=11.0 "$@"

# Flutter wrapper for JSON-goLD

This is a Dart wrapper for [JSON-goLD](https://github.com/piprate/json-gold).

It realizes direct interop between Dart and Go/cgo without any other glue codes by utilizing Dart's [ReceivePort](https://api.dart.dev/stable/2.14.4/dart-isolate/ReceivePort-class.html); it reduces interop code for every platform.

## Note for iOS

Update your project's target iOS version to `11.0` or later; underlying xcframework does not have slice for `armv7` (32-bit) codes.

## Testing on macOS

Although the plugin DOES NOT support macOS as a Flutter plugin, it DOES support running test on macOS.
To run test on macOS, you should firstly run `gomodule/build-mac.sh` and it will generate `gomobile/dist/mac/libld2rdf.dylib`.
After that, you can safely run `flutter test`.

## Build scripts

For Android and iOS, the Flutter plugin project already contains prebuilt binaries. But of course, you can rebuild the binaries using the following scripts (they requires `go` command installed on your machine).

### Android

The following script will build shared object file (`libld2rdf.so`) for `arm64-v8a`, `armeabi-v7a`, `x86`, and `x64` under `android/src/main/jniLibs`:

```
gomodule/build-android.sh
```

### iOS

The following script will build `ios/GoJsonLd2Rdf.xcframework` that supports iPhone 64-bit (`arm64`) and iPhone Simulator (`arm64`/`amd64`):

```
gomodule/build-ios.sh
```

### macOS

The following script will build `gomobile/dist/mac/libld2rdf.dylib` that supports `arm64` and `amd64`:

```
gomodule/build-mac.sh
```

### Windows

The following script will build `gomobile/dist/windows/x86_64/libld2rdf.dll`:

```
gomodule/build-windows.sh
```

But it is expected to run on Linux or such environment; at least the following prerequisites:

- gcc-multilib
- gcc-mingw-w64
- binutils-mingw-w64

## References

- [Async messaging between Flutter and C++ using Dart ffi NativePort](https://gist.github.com/espresso3389/be5674ab4e3154f0b7c43715dcef3d8d)
- [flutter/flutter #63255 How to use async callback between C++ and Dart with FFI?](https://github.com/flutter/flutter/issues/63255)
- [mraleph/go_dart_ffi_example - GitHub](https://github.com/mraleph/go_dart_ffi_example)
- [ReceivePort](https://api.dart.dev/stable/2.14.4/dart-isolate/ReceivePort-class.html)

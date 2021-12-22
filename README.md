# Flutter wrapper for JSON-goLD

This is a part of a Dart wrapper for [JSON-goLD](https://github.com/piprate/json-gold).

It realizes direct interop between Dart and C++ without any other glue codes using Dart's [ReceivePort](https://api.dart.dev/stable/2.14.4/dart-isolate/ReceivePort-class.html); it reduces interop code for every platform.

### Note for iOS

Update your project's target iOS version to `11.0` or later; underlying xcframework does not have slice for `armv7` (32-bit) codes.

### Build scripts

For Android and iOS, the Flutter plugin project already contains prebuilt binaries. But you can rebuild the binaries with the following scripts:

```
gomodule/build-android.sh
gomodule/build-ios.sh
gomodule/build-mac.sh
```

## References

- [Async messaging between Flutter and C++ using Dart ffi NativePort](https://gist.github.com/espresso3389/be5674ab4e3154f0b7c43715dcef3d8d)
- [flutter/flutter #63255 How to use async callback between C++ and Dart with FFI?](https://github.com/flutter/flutter/issues/63255)
- [mraleph/go_dart_ffi_example - GitHub](https://github.com/mraleph/go_dart_ffi_example)
- [ReceivePort](https://api.dart.dev/stable/2.14.4/dart-isolate/ReceivePort-class.html)

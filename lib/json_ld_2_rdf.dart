import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

typedef _InitFunc = int Function(Pointer<Void>);
typedef _InitFuncN = Int64 Function(Pointer<Void>);

typedef _JsonToRdfPortContextStrFunc = void Function(int, int, Pointer<Utf8>);
typedef _JsonToRdfPortContextStrFuncN = Void Function(Int64, Int64, Pointer<Utf8>);

typedef _JsonToRdfPortContextStrBoolFunc = void Function(int, int, Pointer<Utf8>, int);
typedef _JsonToRdfPortContextStrBoolFuncN = Void Function(Int64, Int64, Pointer<Utf8>, Int8);

typedef UrlDownloader = Future<String> Function(String url);

class _Context {
  static int _nextId = 0;
  static final _contexts = <int, _Context>{};

  final int id;
  final UrlDownloader? downloader;
  final _completer = Completer<_Result>();
  _Context._(this.id, this.downloader);

  factory _Context.create(UrlDownloader? downloader) {
    // higher 32-bit is used to determine which jsonToRdf function call.
    final id = _nextId;
    _nextId += 0x100000000; // increment higher 32-bit
    return _contexts[id] = _Context._(id, downloader);
  }

  void complete(_Result result) {
    _completer.complete(result);
    _contexts.remove(id);
  }

  Future<_Result> get future => _completer.future;

  /// handles case of successful/error result
  static bool completeIfPossible(int context, String str) {
    final low32 = context & 0xffffffff;
    if (low32 == 0 || low32 == 0xffffffff) {
      final ctx = _contexts[context & 0xffffffff00000000];
      if (ctx != null) {
        ctx._completer.complete(_Result(context, str));
        return true;
      }
    }
    return false;
  }

  static UrlDownloader? getDownloaderFor(int context) => _contexts[context & 0xffffffff00000000]?.downloader;
}

class _Result {
  final int context;
  final String str;
  _Result(this.context, this.str);

  bool get isError => (context & 0xffffffff) == 0xffffffff;

  void throwIfError() {
    if (isError) throw Exception(str);
  }
}

abstract class JsonLd2Rdf {
  static final _ld2rdfLib = _load();

  static final _InitFunc _init = _ld2rdfLib.lookup<NativeFunction<_InitFuncN>>("JsonToRdfInitSendPort").asFunction();

  static final _JsonToRdfPortContextStrFunc _jsonToRdfSendString =
      _ld2rdfLib.lookup<NativeFunction<_JsonToRdfPortContextStrFuncN>>("JsonToRdfSendString").asFunction();

  static final _JsonToRdfPortContextStrBoolFunc _jsonToRdfAsync =
      _ld2rdfLib.lookup<NativeFunction<_JsonToRdfPortContextStrBoolFuncN>>("JsonToRdfNormalizedAsyncPtr").asFunction();

  static ReceivePort? _port;
  static StreamSubscription<dynamic>? _pub;
  static int? _sendPort;

  static void _ensureInitialized() {
    if (_pub != null) {
      return;
    }

    _sendPort = _init(NativeApi.initializeApiDLData);
    _port = ReceivePort();
    _pub = _port!.listen((message) {
      final list = message;
      final context = list[0] as int;
      final str = list[1] as String;
      if (_Context.completeIfPossible(context, str)) {
        return;
      }
      downloadAndSendbackToGo(context, url: str);
    });
  }

  static void downloadAndSendbackToGo(int context, {required String url}) async {
    String result = "";
    try {
      final downloader = _Context.getDownloaderFor(context)!;
      result = await downloader(url);
    } catch (e) {
      // for error cases, result is ""
    }
    _sendString(context, result);
  }

  /// For non-Flutter codes, if you don't call the function, [main] function may not stop.
  static void shutdown() {
    _pub?.cancel();
    _pub = null;
    _port?.close();
    _port = null;
    _sendPort = null;
  }

  static void _sendString(int context, String message) => using(
        (arena) {
          _jsonToRdfSendString(
            _sendPort!,
            context,
            message.toNativeUtf8(allocator: arena),
          );
        },
      );

  static Future<String> jsonToRdf(String jsonLd, {UrlDownloader? downloader}) => using(
        (arena) async {
          _ensureInitialized();
          final context = _Context.create(downloader);
          _jsonToRdfAsync(
            _port!.sendPort.nativePort,
            context.id,
            jsonLd.toNativeUtf8(allocator: arena),
            downloader != null ? 1 : 0,
          );
          final result = await context.future;
          result.throwIfError();
          return result.str;
        },
      );

  static DynamicLibrary _load() {
    if (_moduleLoader != null) {
      try {
        return _moduleLoader!();
      } catch (e) {
        // fall-through
      }
    }
    return Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(moduleName);
  }

  static String? _moduleName;
  static ModuleLoadFunction? _moduleLoader;

  /// Set custom module `libld2rdf` loading method. If you set loading method, [moduleName] will be reset.
  static set moduleLoader(ModuleLoadFunction? loader) {
    _moduleLoader = loader;
    _moduleName = null;
  }

  static ModuleLoadFunction? get moduleLoader => _moduleLoader;

  /// Set custom module path; If you set the module path, [moduleLoader] will be reset.
  static set moduleName(String moduleName) {
    _moduleLoader = null;
    _moduleName = moduleName;
  }

  static String get moduleName {
    if (_moduleName != null) return _moduleName!;
    if (Platform.isAndroid) return "libld2rdf.so";
    if (Platform.isMacOS) return "gomodule/dist/mac/libld2rdf.dylib";
    throw Exception('Your platform is not currently supported.');
  }
}

typedef ModuleLoadFunction = DynamicLibrary Function();

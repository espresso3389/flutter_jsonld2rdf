import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_ld_2_rdf/json_ld_2_rdf.dart';

void main() {
  const MethodChannel channel = MethodChannel('json_ld_2_rdf');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await JsonLd2Rdf.platformVersion, '42');
  });
}

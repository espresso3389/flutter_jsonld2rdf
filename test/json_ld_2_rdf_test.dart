import 'package:flutter_test/flutter_test.dart';
import 'package:json_ld_2_rdf/json_ld_2_rdf.dart';
import 'package:http/http.dart' as http;

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // for testing on macOS, we should set the module path explicitly.
  JsonLd2Rdf.moduleName = 'gomodule/dist/mac/libld2rdf.dylib';

  const jsonUrl = 'https://json-ld.org/test-suite/tests/toRdf-0028-in.jsonld';
  const jsonUrlExpects =
      '''<http://example.org/fact1> <http://purl.org/dc/terms/title> "Hello World!" <http://example.org/sig1> .
<http://example.org/sig1> <http://purl.org/dc/terms/created> "2011-09-23T20:21:34Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
<http://example.org/sig1> <http://purl.org/security#signatureValue> "OGQzNGVkMzVm4NTIyZTkZDYMmMzQzNmExMgoYzI43Q3ODIyOWM32NjI=" .
<http://example.org/sig1> <http://purl.org/security#signer> <http://payswarm.example.com/i/john/keys/5> .
<http://example.org/sig1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/security#SignedGraph> .
<http://example.org/sig1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> .
''';

  test('jsonUrl', () async {
    expect(await JsonLd2Rdf.jsonToRdf(jsonUrl), jsonUrlExpects);
  });

  const jsonRaw = '''{
  "@context": {
    "sec": "http://purl.org/security#",
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "dc": "http://purl.org/dc/terms/",
    "sec:signer": {"@type": "@id"},
    "dc:created": {"@type": "xsd:dateTime"}
  },
  "@id": "http://example.org/sig1",
  "@type": ["rdf:Graph", "sec:SignedGraph"],
  "dc:created": "2011-09-23T20:21:34Z",
  "sec:signer": "http://payswarm.example.com/i/john/keys/5",
  "sec:signatureValue": "OGQzNGVkMzVm4NTIyZTkZDYMmMzQzNmExMgoYzI43Q3ODIyOWM32NjI=",
  "@graph": {
    "@id": "http://example.org/fact1",
    "dc:title": "Hello World!"
  }
}''';

  // test('jsonRaw', () async {
  //   expect(await JsonLd2Rdf.jsonToRdf(jsonRaw), jsonUrlExpects);
  // });

  // const jsonError = '''{
  // 	"@context": {
  // 	  "@version": 1.1,
  // 	  "@protected": "true",

  // 	  "\$did": "https://ua.poc.loosedays.com/VCTemplate#did",
  // 	  "\$singleText": "https://ua.poc.loosedays.com/VCTemplate#singleText",
  // 	  "\$multiText": "https://ua.poc.loosedays.com/VCTemplate#multiText",
  // 	  "\$number": "https://ua.poc.loosedays.com/VCTemplate#number",
  // 	  "\$boolean": "https://ua.poc.loosedays.com/VCTemplate#boolean",
  // 	  "\$date": "https://ua.poc.loosedays.com/VCTemplate#date"
  // 	}
  // }''';
  // test('jsonError', () async {
  //   expect(await JsonLd2Rdf.jsonToRdf(jsonError), throwsException);
  // });

  // Without the call, main never finishes.
  JsonLd2Rdf.shutdown();
}

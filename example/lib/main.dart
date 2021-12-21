import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:json_ld_2_rdf/json_ld_2_rdf.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Future<String> downloader(url) async {
      print('Downloading $url...');
      final res = await http.get(Uri.parse(url));
      return res.body;
    }

    try {
      const jsonUrl = 'https://json-ld.org/test-suite/tests/toRdf-0028-in.jsonld';
      print(await JsonLd2Rdf.jsonToRdf(jsonUrl, downloader: downloader));
      print(await JsonLd2Rdf.jsonToRdf(jsonUrl));

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
      print(await JsonLd2Rdf.jsonToRdf(jsonRaw, downloader: downloader));
      print(await JsonLd2Rdf.jsonToRdf(jsonRaw));

      const jsonError = '''{
		"@context": {
		  "@version": 1.1,
		  "@protected": "true",
	  
		  "\$did": "https://ua.poc.loosedays.com/VCTemplate#did",
		  "\$singleText": "https://ua.poc.loosedays.com/VCTemplate#singleText",
		  "\$multiText": "https://ua.poc.loosedays.com/VCTemplate#multiText",
		  "\$number": "https://ua.poc.loosedays.com/VCTemplate#number",
		  "\$boolean": "https://ua.poc.loosedays.com/VCTemplate#boolean",
		  "\$date": "https://ua.poc.loosedays.com/VCTemplate#date"
		}
	}''';
      print(await JsonLd2Rdf.jsonToRdf(jsonError));
    } catch (e, s) {
      print('$e: $s');
    }

    // Without the call, main never finishes.
    JsonLd2Rdf.shutdown();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Testing\n'),
        ),
      ),
    );
  }
}

Pod::Spec.new do |s|
  s.name = "ld2rdf"
  s.version = "1.0.0"
  s.license = { :type => "BSD" }
  s.homepage = "https://github.com/espresso3389/json-gold-dart"
  s.summary = "JSON-LD to RDF converter library based on JSON-goLD"
  s.authors = "espresso3389"
  s.source = { :git => "https://github.com/espresso3389/json-gold-dart.git", :tag => "v#{s.version}" }
  s.module_name = "ld2rdf"
  s.header_dir = "ld2rdf"
  s.platforms = { :ios => "9.0" }
  s.ios.deployment_target = '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.vendored_libraries = 'out/lib/ios/libld2rdf.a'
  s.public_header_files = 'out/include/*.h'
  s.header_mappings_dir = 'out/include'
  s.xcconfig = {
    'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/ld2rdf/out/include"'
  }
end

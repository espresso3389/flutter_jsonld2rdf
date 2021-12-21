#import "JsonLd2RdfPlugin.h"
#if __has_include(<json_ld_2_rdf/json_ld_2_rdf-Swift.h>)
#import <json_ld_2_rdf/json_ld_2_rdf-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "json_ld_2_rdf-Swift.h"
#endif

@implementation JsonLd2RdfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftJsonLd2RdfPlugin registerWithRegistrar:registrar];
}
@end

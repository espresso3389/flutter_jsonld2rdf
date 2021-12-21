import Flutter
import UIKit

public class SwiftJsonLd2RdfPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "json_ld_2_rdf", binaryMessenger: registrar.messenger())
    let instance = SwiftJsonLd2RdfPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}

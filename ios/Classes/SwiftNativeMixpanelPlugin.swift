import Flutter
import UIKit

import Mixpanel

public class SwiftNativeMixpanelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_mixpanel", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeMixpanelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "initialize") {
      Mixpanel.initialize(token: call.arguments as! String)
    } else {
      Mixpanel.mainInstance().track(event: call.method)
    }
    result("success")
  }
}

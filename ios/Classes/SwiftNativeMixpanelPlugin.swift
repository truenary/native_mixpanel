import Flutter
import UIKit

import Mixpanel

public class SwiftNativeMixpanelPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_mixpanel", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeMixpanelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
    do {
      
      if (call.method == "initialize") {
        Mixpanel.initialize(token: call.arguments as! String)
      } else if(call.method == "identify") {
        Mixpanel.mainInstance().identify(distinctId: call.arguments as! String)
      } else if(call.method == "alias") {
        Mixpanel.mainInstance().createAlias(call.arguments as! String, distinctId: Mixpanel.mainInstance().distinctId)
      } else if let arguments = call.arguments, let data = (arguments as! String).data(using: .utf8) {

        let properties = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        var sendProperties = [String: String]()
        for (key, value) in properties {
            sendProperties[key] = String(describing: value)
        }
        Mixpanel.mainInstance().track(event: call.method, properties: sendProperties)
      } else {
        Mixpanel.mainInstance().track(event: call.method)
      }

      result(true)
    } catch {
      print(error.localizedDescription)
      result(false)
    }
  }
}

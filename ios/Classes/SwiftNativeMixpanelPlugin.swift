import Flutter
import UIKit

import Mixpanel

@objc public class SwiftNativeMixpanelPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_mixpanel", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeMixpanelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func getPropertiesFromArguments(callArguments: Any?) throws -> Properties? {

    if let arguments = callArguments, let data = (arguments as! String).data(using: .utf8) {

      let properties = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
      var argProperties = [String: String]()
      for (key, value) in properties {
        argProperties[key] = String(describing: value)
      }
      return argProperties;
    }

    return nil;
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
    do {
      
      if (call.method == "initialize") {
        Mixpanel.initialize(token: call.arguments as! String)
      } else if(call.method == "identify") {
        Mixpanel.mainInstance().identify(distinctId: call.arguments as! String)
      } else if(call.method == "alias") {
        Mixpanel.mainInstance().createAlias(call.arguments as! String, distinctId: Mixpanel.mainInstance().distinctId)
      } else if(call.method == "setPeopleProperties") {
        if let argProperties = try self.getPropertiesFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().people.set(properties: argProperties)
        } else {
          result(FlutterError(code: "Parse Error", message: "Could not parse arguments for setPeopleProperties platform call. Needs valid JSON data.", details: nil))
        }
      } else if(call.method == "registerSuperProperties") {
        if let argProperties = try self.getPropertiesFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().registerSuperProperties(argProperties)
        } else {
          result(FlutterError(code: "Parse Error", message: "Could not parse arguments for registerSuperProperties platform call. Needs valid JSON data.", details: nil))
        }
      } else if(call.method == "reset") {
        Mixpanel.mainInstance().reset()
      } else if(call.method == "flush") {
        Mixpanel.mainInstance().flush()
      } else if let argProperties = try self.getPropertiesFromArguments(callArguments: call.arguments) {
        Mixpanel.mainInstance().track(event: call.method, properties: argProperties)
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

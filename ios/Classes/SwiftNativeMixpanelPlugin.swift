import Flutter
import UIKit

import Mixpanel

@objc public class SwiftNativeMixpanelPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_mixpanel", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeMixpanelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private func toMPType(_ value: Any) -> MixpanelType? {
    if let isLikedNumber = value as? NSNumber, isLikedNumber === kCFBooleanTrue || isLikedNumber === kCFBooleanFalse {
      return value as! Bool
    } else if(value is String) {
      return value as! String
    } else if(value is Int) {
      return value as! Int
    } else if(value is Double) {
      return value as! Double
    } else if(value is NSArray) {
      var typedArr = [MixpanelType]();
      for arrValue in (value as! NSArray) {
        if let typedValue = toMPType(arrValue) {
          typedArr.append(typedValue)
        }
      }
      return typedArr;
    }
    return nil;
  }

  private func convertTypes(properties: [String: Any]) -> [String: MixpanelType] {
    var argProperties = [String: MixpanelType]()
    for(key, value) in properties {
      if let typedValue = toMPType(value) {
        argProperties[key] = typedValue
      }
    }
    return argProperties;
  }

  private func getPropertiesFromArguments(callArguments: Any?) throws -> Properties? {
    if let arguments = callArguments, let data = (arguments as! String).data(using: .utf8) {
      let properties = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
      return convertTypes(properties: properties);
    }
    return nil;
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
    do {
      if (call.method == "initialize") {
        Mixpanel.initialize(token: call.arguments as! String)
      } else if(call.method == "identify") {
        Mixpanel.mainInstance().identify(distinctId: call.arguments as! String, usePeople: false)
      } else if (call.method == "identifyPeople") {
        Mixpanel.mainInstance().identify(distinctId: call.arguments as! String, usePeople: true)
      } else if(call.method == "alias") {
        Mixpanel.mainInstance().createAlias(call.arguments as! String, distinctId: Mixpanel.mainInstance().distinctId)
      } else if(call.method == "setPeopleProperties") {
        if let argProperties = try self.getPropertiesFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().people.set(properties: argProperties)
        } else {
          result(FlutterError(code: "Parse Error", message: "Could not parse arguments for setPeopleProperties platform call. Needs valid JSON data.", details: nil))
        }
      } else if(call.method == "setPeoplePropertiesOnce") {
        if let argProperties = try self.getPropertiesFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().people.setOnce(properties: argProperties)
        } else {
          result(FlutterError(code: "Parse Error", message: "Could not parse arguments for setPeoplePropertiesOnce platform call. Needs valid JSON data.", details: nil))
        }
      } else if(call.method == "incrementPeopleProperties") {
        if let argProperties = try self.getPropertiesFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().people.increment(properties: argProperties)
        } else {
          result(FlutterError(code: "Parse Error", message: "Could not parse arguments for incrementPeopleProperties platform call. Needs valid JSON data.", details: nil))
        }
      } else if(call.method == "registerSuperProperties") {
        if let argProperties = try self.getPropertiesFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().registerSuperProperties(argProperties)
        } else {
          result(FlutterError(code: "Parse Error", message: "Could not parse arguments for registerSuperProperties platform call. Needs valid JSON data.", details: nil))
        }
      } else if(call.method == "registerSuperPropertiesOnce") {
        if let argProperties = try self.getPropertiesFromArguments(callArguments: call.arguments) {
          Mixpanel.mainInstance().registerSuperPropertiesOnce(argProperties)
        } else {
          result(FlutterError(code: "Parse Error", message: "Could not parse arguments for registerSuperPropertiesOnce platform call. Needs valid JSON data.", details: nil))
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

  public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Mixpanel.mainInstance().people.addPushDeviceToken(deviceToken)
  }
}

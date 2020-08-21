package com.example.native_mixpanel

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import android.util.Log
import org.json.JSONObject
import com.mixpanel.android.mpmetrics.MixpanelAPI
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class NativeMixpanelPlugin (): FlutterPlugin, MethodCallHandler {
  lateinit var _context: Context
  private var mixpanel: MixpanelAPI? = null

  private fun jsonToNumberMap(jsonObj: JSONObject): Map<String, Double> {
    var map = HashMap<String, Double>();
    var keys: Iterator<String> = jsonObj.keys();
    while (keys.hasNext()) {
      var key = keys.next();
      map.put(key, jsonObj.getDouble(key));
    }
    return map;
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_mixpanel")
    val plugin = NativeMixpanelPlugin()
    plugin._context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(plugin)
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "native_mixpanel")
      val plugin = NativeMixpanelPlugin()
      plugin._context = registrar.context().applicationContext
      channel.setMethodCallHandler(plugin)
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "initialize") {
      mixpanel = MixpanelAPI.getInstance(context, call.arguments.toString())
      result.success("Init success..")

    } else if(call.method == "identify") {
      mixpanel?.identify(call.arguments.toString())
      result.success("Identify success..")
    } else if(call.method == "identifyPeople") {
      val id = call.arguments.toString()
      mixpanel?.identify(id)
      mixpanel?.people?.identify(id)
      result.success("Identify people success..")
    } else if(call.method == "setPushRegistrationId") {
      val token = call.arguments.toString()
      mixpanel?.people?.setPushRegistrationId(token)
      result.success("addPushDeviceToken success..")
    } else if(call.method == "alias") {
      mixpanel?.alias(call.arguments.toString(), mixpanel?.getDistinctId())
      result.success("Alias success..")
    } else if(call.method == "setPeopleProperties") {
      if (call.arguments == null) {
        result.error("Parse Error", "Arguments required for setPeopleProperties platform call", null)
      } else {
        val json = JSONObject(call.arguments.toString())
        mixpanel?.people?.set(json)
        result.success("Set People Properties success..")
      }
    } else if(call.method == "setPeoplePropertiesOnce") {
      if (call.arguments == null) {
        result.error("Parse Error", "Arguments required for setPeoplePropertiesOnce platform call", null)
      } else {
        val json = JSONObject(call.arguments.toString())
        mixpanel?.people?.setOnce(json)
        result.success("Set People Properties success..")
      }
    } else if(call.method == "incrementPeopleProperties") {
      if (call.arguments == null) {
        result.error("Parse Error", "Arguments required for incrementPeopleProperties platform call", null)
      } else {
        val map = jsonToNumberMap(JSONObject(call.arguments.toString()))
        mixpanel?.people?.increment(map)
        result.success("Increment People Properties success..")
      }
    } else if(call.method == "registerSuperProperties") {
      if (call.arguments == null) {
        result.error("Parse Error", "Arguments required for registerSuperProperties platform call", null)
      } else {
        val json = JSONObject(call.arguments.toString())
        mixpanel?.registerSuperProperties(json)
        result.success("Register Properties success..")
      }
    } else if(call.method == "registerSuperPropertiesOnce") {
      if (call.arguments == null) {
        result.error("Parse Error", "Arguments required for registerSuperPropertiesOnce platform call", null)
      } else {
        val json = JSONObject(call.arguments.toString())
        mixpanel?.registerSuperPropertiesOnce(json)
        result.success("Register Properties Once success..")
      }
    } else if (call.method == "reset") {
      mixpanel?.reset()
      result.success("Reset success..")
    } else if (call.method == "flush") {
      mixpanel?.flush()
      result.success("Flush success..")
    } else {
      if(call.arguments == null) {
        mixpanel?.track(call.method)  
      } else {
        val json = JSONObject(call.arguments.toString())
        mixpanel?.track(call.method, json)
      }      
      result.success("Track success..")
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}

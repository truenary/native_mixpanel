package com.example.native_mixpanel

import android.content.Context
import android.util.Log
import org.json.JSONObject
import com.mixpanel.android.mpmetrics.MixpanelAPI
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class NativeMixpanelPlugin: MethodCallHandler {

  private var mixpanel: MixpanelAPI? = null

  companion object {

    var ctxt: Context? = null
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      ctxt = registrar.context()
      val channel = MethodChannel(registrar.messenger(), "native_mixpanel")
      channel.setMethodCallHandler(NativeMixpanelPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "initialize") {
      mixpanel = MixpanelAPI.getInstance(ctxt, call.arguments.toString())
      result.success("Init success..")

    } else if(call.method == "identify") {
      mixpanel?.identify(call.arguments.toString())
      result.success("Identify success..")

    } else if(call.method == "alias") {
      mixpanel?.alias(call.arguments.toString(), mixpanel?.getDistinctId())
      result.success("Alias success..")

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
}

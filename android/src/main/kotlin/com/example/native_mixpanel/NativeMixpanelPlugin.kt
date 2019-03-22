package com.example.native_mixpanel

import android.content.Context
import android.util.Log
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
    }
    else {
      mixpanel?.track(call.method)
      result.success("Track success..")
    }
  }
}

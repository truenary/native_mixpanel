import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show debugPrint;

abstract class _Mixpanel {

  Future track(String eventName, [dynamic props]);
}

class _MixpanelOptedOut extends _Mixpanel {

  Future track(String eventName, [dynamic props]) {
    // nothing to do when opted out
    return Future.value();
  }
}

class _MixpanelOptedIn extends _Mixpanel {
  final MethodChannel _channel = const MethodChannel('native_mixpanel');

  Future track(String eventName, [dynamic props]) async {
    return await _channel.invokeMethod(eventName, props);
  }
}

class _MixpanelDebugged extends _Mixpanel {

  final _Mixpanel child;

  _MixpanelDebugged({this.child});

  Future track(String eventName, [dynamic props]) async {
    String msg = """
    Sending event: $eventName with properties: $props
    """;
    debugPrint(msg);

    return await this.child.track(eventName, props);
  }  
}

class Mixpanel extends _Mixpanel {

  final bool isDebug;
  final bool isOptedOut;

  _Mixpanel _mp;

  Mixpanel({
    this.isDebug,
    this.isOptedOut,
  }) {

    _Mixpanel _mixpanel = isOptedOut ? _MixpanelOptedOut() : _MixpanelOptedIn();

    if (isDebug) _mp = _MixpanelDebugged(child: _mixpanel);
    else _mp = _mixpanel;
  }

  Future initialize(String token) {
    return this._mp.track('initialize', token);
  }

  Future identify(String distinctId) {
    return this._mp.track('identify', distinctId);
  }

  Future alias(String alias) {
    return this._mp.track('alias', alias);
  }

  Future track(String eventName, [dynamic props]) {
    return this._mp.track(eventName, props);
  }
}

import 'dart:async';
import 'dart:convert';

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
  final bool shouldLogEvents;
  final bool isOptedOut;

  _Mixpanel _mp;

  Mixpanel({
    this.shouldLogEvents,
    this.isOptedOut,
  }) {
    _Mixpanel _mixpanel = isOptedOut ? _MixpanelOptedOut() : _MixpanelOptedIn();

    if (shouldLogEvents)
      _mp = _MixpanelDebugged(child: _mixpanel);
    else
      _mp = _mixpanel;
  }

  Future initialize(String token) {
    return this._mp.track('initialize', token);
  }

  Future identify(String distinctId) {
    return this._mp.track('identify', distinctId);
  }

  Future identifyPeople(String distinctId) {
    return this._mp.track('identifyPeople', distinctId);
  }

  Future alias(String alias) {
    return this._mp.track('alias', alias);
  }

  Future setPeopleProperties(Map<String, dynamic> props) {
    return this._mp.track('setPeopleProperties', jsonEncode(props));
  }

  Future incrementPeopleProperties(Map<String, dynamic> props) {
    return this._mp.track('incrementPeopleProperties', jsonEncode(props));
  }

  Future registerSuperProperties(Map<String, dynamic> props) {
    return this._mp.track('registerSuperProperties', jsonEncode(props));
  }

  Future reset() {
    return this._mp.track('reset');
  }

  Future flush() {
    return this._mp.track('flush');
  }

  Future track(String eventName, [dynamic props]) {
    return this._mp.track(eventName, jsonEncode(props));
  }
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_mixpanel/native_mixpanel.dart';

void main() {
  const MethodChannel channel = MethodChannel('native_mixpanel');
  Mixpanel mixpanel = Mixpanel(
    isDebug: true,
    isOptedOut: true,
  );

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await mixpanel.initialize('dummytoken'), null);
  });
}

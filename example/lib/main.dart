import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_mixpanel/native_mixpanel.dart';

void main() => runApp(MyApp(
      mixpanel: Mixpanel(
        shouldLogEvents: true,
        isOptedOut: false,
        terminatedEvent: 'App force quit',
      ),
    ));

class MyApp extends StatefulWidget {
  final Mixpanel mixpanel;

  MyApp({
    @required this.mixpanel,
  }) : assert(mixpanel != null);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _statusMessage = 'Trying to send track event';
  int count;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    count = 0;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String initStatus;
    String eventName = 'First App Open';
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await widget.mixpanel.initialize('your-token-here');
      await widget.mixpanel.track(eventName, {'Math': 'divide'});
      initStatus = 'Event Sent: $eventName';
    } on PlatformException {
      initStatus = 'Failed to send event: $eventName';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _statusMessage = initStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: <Widget>[
            Center(
              child: Text(
                '$_statusMessage\n',
                style: TextStyle(
                  fontSize: 12.0,
                  height: 18.0 / 12.0,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel.identify('101');
                },
                child: Text('Set Identity'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel.identifyPeople('102');
                },
                child: Text('Set People Identity'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel.alias('premium');
                },
                child: Text('Set Alias'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel.setPeopleProperties({'genre': 'rock'});
                },
                child: Text('Set People Properties'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel
                      .setPeoplePropertiesOnce({'genre': 'rap'});
                },
                child: Text('Set People Properties Once'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel.incrementPeopleProperties(
                      {'purchase': 12.65, 'count': 6});
                },
                child: Text('Increment People Properties'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel
                      .registerSuperProperties({'gender': 'he'});
                },
                child: Text('Register Super Properties'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel
                      .registerSuperPropertiesOnce({'height': '6 foot'});
                },
                child: Text('Register Super Properties Once'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel.track('Test Event', {
                    'integer test': 23,
                    'double test': 42.69,
                    'boolean test': true,
                    'string test': 'string here',
                    'list integer test': [1, 2],
                    'list double test': [1.11, 2.22],
                    'list boolean test': [true, false],
                    'list string test': ['first', 'second'],
                    'list of lists test': [
                      'string here',
                      [1, 2, 3],
                      [true, false, false],
                      69.9,
                    ],
                  });
                },
                child: Text('Send Test Event'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel.reset();
                },
                child: Icon(Icons.restore),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () async {
                  await widget.mixpanel.flush();
                },
                child: Text('Flush'),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.mixpanel
                .track('Added to Cart', {'ProductId': 'product-${count++}'});
          },
          child: Icon(Icons.plus_one),
        ),
      ),
    );
  }
}

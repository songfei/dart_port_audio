import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:port_audio/port_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  AudioInputStream? stream;
  StreamSubscription? audioSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      // platformVersion = await PortAudio.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    AudioDeviceManager.instance;

    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            FlatButton(
              onPressed: () {
                var defaultDevice = AudioDeviceManager.instance.defaultInputDevice;

                print(defaultDevice);

                if (stream != null) {
                  audioSubscription?.cancel();
                  stream!.stop();
                  stream!.close();
                  stream = null;
                }

                stream = AudioDeviceManager.instance.createInputStream(device: defaultDevice);
                audioSubscription = stream?.stream.listen((event) {
                  if (event is List) {
                    print(event.length);
                  }
                });

                stream!.start();
              },
              child: const Text('开始'),
            ),
            FlatButton(
              onPressed: () {
                audioSubscription?.cancel();
                stream?.stop();
                stream?.close();
                stream = null;
              },
              child: const Text('结束'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:port_audio/port_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  AudioInputStream? stream1;
  AudioInputStream? stream2;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    var defaultInputDevice = AudioDeviceManager.instance.defaultInputDevice;
    _platformVersion = defaultInputDevice.toString();

    List<AudioDeviceInfo> inputDevices = AudioDeviceManager.instance.inputDevices;

    print(inputDevices);

    stream1 = AudioDeviceManager.instance.createInputStream(device: inputDevices[1]);
    stream2 = AudioDeviceManager.instance.createInputStream(device: inputDevices[2]);

    print('${stream1!.nativeStreamPtr} ${stream2!.nativeStreamPtr}');

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    print(appDocPath);

    File file1 = File('./test1.pcm');
    File file2 = File('./test2.pcm');
    List<int> buffer1 = [];
    List<int> buffer2 = [];

    stream1!.stream.listen((event) {
      buffer1.addAll(event);
    }, onDone: () {
      file1.writeAsBytesSync(buffer1);
    });

    stream2!.stream.listen((event) {
      buffer2.addAll(event);
    }, onDone: () {
      file2.writeAsBytesSync(buffer2);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              FlatButton(
                  onPressed: () {
                    stream1!.start();
                    stream2!.start();
                  },
                  child: Text('开始')),
              FlatButton(
                  onPressed: () {
                    stream1!.stop();
                    stream1!.close();

                    stream2!.stop();
                    stream2!.close();
                  },
                  child: Text('结束')),
            ],
          ),
        ),
      ),
    );
  }
}

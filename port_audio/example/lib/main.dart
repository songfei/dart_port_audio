import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:port_audio/port_audio.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  AudioDeviceManager.instance.isDebug = true;

  File file = File('timepb.bin');

  List<int> data = [
    8,
    1,
    18,
    249,
    1,
    10,
    32,
    57,
    52,
    52,
    54,
    52,
    101,
    101,
    56,
    55,
    53,
    100,
    98,
    97,
    51,
    48,
    57,
    100,
    99,
    98,
    98,
    98,
    52,
    97,
    54,
    51,
    57,
    50,
    48,
    50,
    100,
    97,
    98,
    18,
    5,
    49,
    46,
    49,
    46,
    56,
    24,
    206,
    8,
    32,
    0,
    40,
    1,
    48,
    5,
    82,
    24,
    232,
    175,
    183,
    229,
    141,
    135,
    231,
    186,
    167,
    231,
    137,
    136,
    230,
    156,
    172,
    229,
    144,
    142,
    228,
    189,
    191,
    231,
    148,
    168,
    90,
    97,
    227,
    128,
    144,
    230,
    150,
    176,
    229,
    162,
    158,
    233,
    159,
    179,
    230,
    160,
    135,
    228,
    184,
    147,
    233,
    161,
    185,
    227,
    128,
    145,
    230,
    152,
    147,
    230,
    183,
    183,
    233,
    159,
    179,
    230,
    160,
    135,
    229,
    175,
    185,
    230,
    175,
    148,
    229,
    173,
    166,
    228,
    185,
    160,
    10,
    227,
    128,
    144,
    228,
    189,
    147,
    233,
    170,
    140,
    230,
    128,
    167,
    232,
    131,
    189,
    228,
    188,
    152,
    229,
    140,
    150,
    227,
    128,
    145,
    232,
    139,
    177,
    232,
    175,
    173,
    229,
    173,
    166,
    228,
    185,
    160,
    230,
    155,
    180,
    229,
    138,
    160,
    233,
    161,
    186,
    231,
    149,
    133,
    98,
    6,
    8,
    160,
    254,
    198,
    140,
    6,
    104,
    195,
    235,
    215,
    33,
    162,
    1,
    58,
    104,
    116,
    116,
    112,
    115,
    58,
    47,
    47,
    115,
    116,
    117,
    100,
    121,
    46,
    113,
    113,
    46,
    99,
    111,
    109,
    47,
    100,
    111,
    119,
    110,
    108,
    111,
    97,
    100,
    63,
    99,
    116,
    61,
    116,
    105,
    112,
    38,
    97,
    112,
    112,
    61,
    101,
    100,
    117,
    95,
    109,
    105,
    100,
    100,
    108,
    101,
    95,
    115,
    99,
    104,
    111,
    111,
  ];

  file.writeAsBytesSync(data);

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

    if (stream != null) {
      audioSubscription?.cancel();
      stream!.stop();
      stream!.close();
      stream = null;
    }

    var defaultDevice = AudioDeviceManager.instance.defaultInputDevice;

    stream = await AudioDeviceManager.instance.createInputStream(device: defaultDevice);

    print(stream);

    audioSubscription = stream?.stream.listen((event) {
      if (event is List) {
        print(event.length);
      }
    });

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
                // print(AudioDeviceManager.instance.inputDevices);

                // print(defaultDevice);

                stream!.start();
              },
              child: const Text('开始'),
            ),
            FlatButton(
              onPressed: () {
                stream!.stop();
              },
              child: const Text('结束'),
            ),
            FlatButton(
              onPressed: () {
                stream!.close();
              },
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }
}

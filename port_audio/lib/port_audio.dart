import 'dart:async';

import 'package:flutter/services.dart';

export 'src/audio_device_manager.dart';
export 'src/audio_input_stream.dart';

class PortAudio {
  static const MethodChannel _channel = MethodChannel('port_audio');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

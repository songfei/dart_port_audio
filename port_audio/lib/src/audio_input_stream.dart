import 'dart:ffi';
import 'dart:isolate';

import 'package:port_audio/generated/native_bindings.dart';

import 'native_library.dart';

class AudioInputStream {
  AudioInputStream({
    required this.nativeStreamPtr,
    required this.port,
  });

  final ReceivePort port;
  final Pointer<NativeAudioStream> nativeStreamPtr;

  bool isRunning = false;

  Stream<dynamic> get stream {
    return port;
  }

  void start() {
    if (!isRunning) {
      nativeLibrary.port_audio_native_start_input_stream(nativeStreamPtr);
      isRunning = true;
    }
  }

  void stop() {
    if (isRunning) {
      nativeLibrary.port_audio_native_stop_input_stream(nativeStreamPtr);
      isRunning = false;
    }
  }

  void close() {
    if (isRunning) {
      nativeLibrary.port_audio_native_abort_input_stream(nativeStreamPtr);
    }
    nativeLibrary.port_audio_native_destroy_input_stream(nativeStreamPtr);
    port.close();
  }
}

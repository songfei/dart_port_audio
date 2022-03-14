import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:port_audio/generated/native_bindings.dart';

import 'audio_device_manager.dart';
import 'native_library.dart';

// Logger _log = Logger('PortAudio');

class AudioInputStream {
  AudioInputStream({
    required this.nativeStreamPtr,
    required this.port,
    this.isDebug = false,
  });

  final bool isDebug;
  final ReceivePort port;
  final Pointer<NativeAudioStream> nativeStreamPtr;

  bool isRunning = false;
  bool isClosed = false;

  Stream<dynamic> get stream {
    return port;
  }

  Future<void> start() async {
    if (isClosed) {
      return;
    }
    if (!isRunning) {
      String callbackId = AudioDeviceManager.instance.uuid();
      nativeLibrary.port_audio_native_start_input_stream(nativeStreamPtr, callbackId.toNativeUtf8().cast());
      isRunning = true;
      await AudioDeviceManager.instance.waitResult(callbackId);
    }
  }

  Future<void> stop() async {
    if (isClosed) {
      return;
    }
    if (isRunning) {
      String callbackId = AudioDeviceManager.instance.uuid();
      nativeLibrary.port_audio_native_stop_input_stream(nativeStreamPtr, callbackId.toNativeUtf8().cast());
      await AudioDeviceManager.instance.waitResult(callbackId);
      isRunning = false;
    }
  }

  Future<void> close() async {
    if (isClosed) {
      return;
    }
    if (isRunning) {
      String callbackId = AudioDeviceManager.instance.uuid();
      nativeLibrary.port_audio_native_abort_input_stream(nativeStreamPtr, callbackId.toNativeUtf8().cast());
      await AudioDeviceManager.instance.waitResult(callbackId);
      isRunning = false;
    }

    String callbackId = AudioDeviceManager.instance.uuid();
    nativeLibrary.port_audio_native_destroy_input_stream(nativeStreamPtr, callbackId.toNativeUtf8().cast());
    await AudioDeviceManager.instance.waitResult(callbackId);
    port.close();
    isClosed = true;
  }
}

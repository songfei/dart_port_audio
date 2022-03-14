import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';
import 'package:port_audio/generated/native_bindings.dart';
import 'package:port_audio/src/native_library.dart';
import 'package:uuid/uuid.dart';

import 'audio_input_stream.dart';

Logger _log = Logger('PortAudio');

class PortAudioException implements Exception {
  PortAudioException([
    this.code = 0,
    this.message = '',
  ]);

  final int code;
  final String message;
}

class CreateInputAudioStreamException extends PortAudioException {
  CreateInputAudioStreamException(
    int code,
    String message,
  ) : super(code, message);
}

class StartInputAudioStreamException extends PortAudioException {
  StartInputAudioStreamException(
    int code,
    String message,
  ) : super(code, message);
}

class StopInputAudioStreamException extends PortAudioException {
  StopInputAudioStreamException(
    int code,
    String message,
  ) : super(code, message);
}

class AbortInputAudioStreamException extends PortAudioException {
  AbortInputAudioStreamException(
    int code,
    String message,
  ) : super(code, message);
}

class DestoryInputAudioStreamException extends PortAudioException {
  DestoryInputAudioStreamException(
    int code,
    String message,
  ) : super(code, message);
}

enum SampleFormat {
  int16,
  float32,
}

class AudioDeviceInfo {
  AudioDeviceInfo({
    required this.deviceIndex,
    required this.name,
    required this.maxInputChannelCount,
    required this.maxOutputChannelCount,
    required this.defaultSamplingRate,
  });

  final int deviceIndex;
  final String name;
  final int maxInputChannelCount;
  final int maxOutputChannelCount;

  final double defaultSamplingRate;

  @override
  String toString() {
    return 'AudioDeviceInfo{deviceIndex: $deviceIndex, name: $name, maxInputChannelCount: $maxInputChannelCount, maxOutputChannelCount: $maxOutputChannelCount, defaultSamplingRate: $defaultSamplingRate}';
  }
}

class AudioDeviceManager {
  static AudioDeviceManager? _instance;

  AudioDeviceManager._() {
    nativeLibrary.port_audio_native_initialize(NativeApi.initializeApiDLData, callbackPort.sendPort.nativePort);
    callbackPort.listen((message) {
      int callbackType = message[0];
      String callbackId = message[1];
      int code = message[2];
      int resultPointerAddress = message[3];

      Completer<dynamic>? completer = callbackMap[callbackId];
      if (completer != null) {
        // create input stream
        if (callbackType == 1) {
          if (code == 0) {
            Pointer<NativeAudioStream> pointer = Pointer.fromAddress(resultPointerAddress).cast<NativeAudioStream>();
            completer.complete(pointer);
          } else {
            throw (CreateInputAudioStreamException(code, ''));
          }
        }

        // start input stream
        else if (callbackType == 2) {
          if (code == 0) {
            completer.complete();
          } else {
            throw (StartInputAudioStreamException(code, ''));
          }
        }

        // stop input stream
        else if (callbackType == 3) {
          if (code == 0) {
            completer.complete();
          } else {
            throw (StopInputAudioStreamException(code, ''));
          }
        }

        // stop input stream
        else if (callbackType == 4) {
          if (code == 0) {
            completer.complete();
          } else {
            throw (AbortInputAudioStreamException(code, ''));
          }
        }

        // stop input stream
        else if (callbackType == 5) {
          if (code == 0) {
            completer.complete();
          } else {
            throw (DestoryInputAudioStreamException(code, ''));
          }
        }
      }
    });
  }

  static AudioDeviceManager get instance => _instance ??= AudioDeviceManager._();

  bool isDebug = false;
  final callbackPort = ReceivePort();
  final Map<String, Completer<dynamic>> callbackMap = {};
  final _uuid = const Uuid();

  Future<dynamic> waitResult(String callbackId) {
    Completer<dynamic> completer = Completer();
    callbackMap[callbackId] = completer;
    return completer.future;
  }

  String uuid() {
    return _uuid.v4();
  }

  AudioDeviceInfo deviceInfoFromNative(NativeAudioDeviceInfo nativeDeviceInfo) {
    AudioDeviceInfo deviceInfo = AudioDeviceInfo(
      deviceIndex: nativeDeviceInfo.deviceIndex,
      name: nativeDeviceInfo.name.cast<Utf8>().toDartString(),
      maxInputChannelCount: nativeDeviceInfo.maxInputChannelCount,
      maxOutputChannelCount: nativeDeviceInfo.maxOutputChannelCount,
      defaultSamplingRate: nativeDeviceInfo.defaultSamplingRate,
    );
    return deviceInfo;
  }

  List<AudioDeviceInfo> deviceInfoListFromNative(NativeAudioDeviceInfoList nativeDeviceInfoList) {
    List<AudioDeviceInfo> deviceInfoList = [];
    for (int i = 0; i < nativeDeviceInfoList.count; i++) {
      Pointer<Pointer<NativeAudioDeviceInfo>> list = nativeDeviceInfoList.list;
      Pointer<NativeAudioDeviceInfo> info = list[i];
      deviceInfoList.add(deviceInfoFromNative(info.ref));
    }
    return deviceInfoList;
  }

  List<AudioDeviceInfo> get inputDevices {
    DateTime? time;
    if (isDebug) {
      time = DateTime.now();
    }
    Pointer<NativeAudioDeviceInfoList> nativeDeviceInfoListPtr = nativeLibrary.port_audio_native_get_input_device_list();
    List<AudioDeviceInfo> deviceInfoList = deviceInfoListFromNative(nativeDeviceInfoListPtr.ref);
    nativeLibrary.port_audio_native_destroy_device_info_list(nativeDeviceInfoListPtr);
    if (isDebug) {
      if (time != null) {
        _log.info('AudioDeviceManager.inputDevices 执行时间:${DateTime.now().difference(time).inMicroseconds / 1000.0} ms');
      }
    }
    return deviceInfoList;
  }

  List<AudioDeviceInfo> get outputDevices {
    Pointer<NativeAudioDeviceInfoList> nativeDeviceInfoListPtr = nativeLibrary.port_audio_native_get_output_device_list();
    List<AudioDeviceInfo> deviceInfoList = deviceInfoListFromNative(nativeDeviceInfoListPtr.ref);
    nativeLibrary.port_audio_native_destroy_device_info_list(nativeDeviceInfoListPtr);

    return deviceInfoList;
  }

  AudioDeviceInfo? get defaultInputDevice {
    Pointer<NativeAudioDeviceInfo> nativeDeviceInfoPtr = nativeLibrary.port_audio_native_get_default_input_device();
    AudioDeviceInfo? deviceInfo;
    if (nativeDeviceInfoPtr != nullptr) {
      deviceInfo = deviceInfoFromNative(nativeDeviceInfoPtr.ref);
      nativeLibrary.port_audio_native_destroy_device_info(nativeDeviceInfoPtr);
    }

    return deviceInfo;
  }

  AudioDeviceInfo? get defaultOutputDevice {
    Pointer<NativeAudioDeviceInfo> nativeDeviceInfoPtr = nativeLibrary.port_audio_native_get_default_output_device();
    AudioDeviceInfo? deviceInfo;
    if (nativeDeviceInfoPtr != nullptr) {
      deviceInfo = deviceInfoFromNative(nativeDeviceInfoPtr.ref);
      nativeLibrary.port_audio_native_destroy_device_info(nativeDeviceInfoPtr);
    }

    return deviceInfo;
  }

  Future<AudioInputStream?> createInputStream({
    int channelCount = 1,
    double samplingRate = 16000,
    AudioDeviceInfo? device,
    int frameCountPreBuffer = 320,
    SampleFormat sampleFormat = SampleFormat.int16,
  }) async {
    ReceivePort port = ReceivePort();

    device ??= defaultInputDevice;

    AudioInputStream? inputStream;

    String callbackId = _uuid.v4();

    if (device != null) {
      nativeLibrary.port_audio_native_create_input_stream(
        device.deviceIndex,
        port.sendPort.nativePort,
        channelCount,
        sampleFormat.index,
        samplingRate,
        frameCountPreBuffer,
        callbackId.toNativeUtf8().cast(),
      );

      Pointer<NativeAudioStream> pointer = await waitResult(callbackId);

      // print('port: ${port.sendPort.nativePort}');

      return AudioInputStream(
        nativeStreamPtr: pointer,
        port: port,
        isDebug: isDebug,
      );
    }

    return inputStream;
  }

  void dispose() {
    nativeLibrary.port_audio_native_terminate();
  }
}

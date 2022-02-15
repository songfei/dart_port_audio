import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:port_audio/generated/native_bindings.dart';
import 'package:port_audio/src/native_library.dart';

import 'audio_input_stream.dart';

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
    nativeLibrary.port_audio_native_initialize(NativeApi.initializeApiDLData);
  }

  static AudioDeviceManager get instance => _instance ??= AudioDeviceManager._();

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
    Pointer<NativeAudioDeviceInfoList> nativeDeviceInfoListPtr = nativeLibrary.port_audio_native_get_input_device_list();
    List<AudioDeviceInfo> deviceInfoList = deviceInfoListFromNative(nativeDeviceInfoListPtr.ref);
    nativeLibrary.port_audio_native_destroy_device_info_list(nativeDeviceInfoListPtr);
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
    if (nativeDeviceInfoPtr != nullptr) {
      AudioDeviceInfo deviceInfo = deviceInfoFromNative(nativeDeviceInfoPtr.ref);
      nativeLibrary.port_audio_native_destroy_device_info(nativeDeviceInfoPtr);
      return deviceInfo;
    }
    return null;
  }

  AudioDeviceInfo? get defaultOutputDevice {
    Pointer<NativeAudioDeviceInfo> nativeDeviceInfoPtr = nativeLibrary.port_audio_native_get_default_output_device();
    if (nativeDeviceInfoPtr != nullptr) {
      AudioDeviceInfo deviceInfo = deviceInfoFromNative(nativeDeviceInfoPtr.ref);
      nativeLibrary.port_audio_native_destroy_device_info(nativeDeviceInfoPtr);
      return deviceInfo;
    }
    return null;
  }

  AudioInputStream? createInputStream({
    int channelCount = 1,
    double samplingRate = 16000,
    AudioDeviceInfo? device,
    int frameCountPreBuffer = 3200,
    SampleFormat sampleFormat = SampleFormat.int16,
  }) {
    ReceivePort port = ReceivePort();

    device ??= defaultInputDevice;

    if (device != null) {
      Pointer<NativeAudioStream> streamPtr = nativeLibrary.port_audio_native_create_input_stream(
        device.deviceIndex,
        port.sendPort.nativePort,
        channelCount,
        sampleFormat.index,
        samplingRate,
        frameCountPreBuffer,
      );

      // print('port: ${port.sendPort.nativePort}');

      return AudioInputStream(
        nativeStreamPtr: streamPtr,
        port: port,
      );
    }

    return null;
  }

  void dispose() {
    nativeLibrary.port_audio_native_terminate();
  }
}

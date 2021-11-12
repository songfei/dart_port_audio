import 'dart:ffi';
import 'dart:io';

import '../generated/native_bindings.dart';

final DynamicLibrary dynamicLibrary = Platform.isAndroid ? DynamicLibrary.open("libport_audio_native.so") : DynamicLibrary.process();
final nativeLibrary = NativeLibrary(dynamicLibrary);

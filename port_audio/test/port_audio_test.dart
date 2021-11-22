import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:port_audio/port_audio.dart';

void main() {
  const MethodChannel channel = MethodChannel('port_audio');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PortAudio.platformVersion, '42');
  });
}

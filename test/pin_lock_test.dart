import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_lock/pin_lock.dart';

void main() {
  const MethodChannel channel = MethodChannel('pin_lock');

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
    expect(await PinLock.platformVersion, '42');
  });
}

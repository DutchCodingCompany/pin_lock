import 'dart:async';

import 'package:flutter/services.dart';

class PinLock {
  static const MethodChannel _channel = MethodChannel('pin_lock');

  static Future<String> get platformVersion async {
    final String version =
        await _channel.invokeMethod('getPlatformVersion') as String;
    return version;
  }
}

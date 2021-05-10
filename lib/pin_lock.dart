import 'dart:async';

import 'package:flutter/services.dart';

export 'package:pin_lock/src/entities/authenticator.dart';
export 'package:pin_lock/src/entities/lock_controller.dart';
export 'package:pin_lock/src/entities/value_objects.dart';
export 'package:pin_lock/src/presentation/authentication_setup_widget.dart';
export 'package:pin_lock/src/presentation/authenticator_widget.dart';
export 'package:pin_lock/src/presentation/builders.dart';
export 'package:pin_lock/src/presentation/widget_configurations.dart';
export 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';
export 'package:pin_lock/src/repositories/pin_repository.dart';

class PinLock {
  static const MethodChannel _channel = MethodChannel('pin_lock');
}

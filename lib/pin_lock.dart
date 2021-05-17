import 'dart:async';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/lock_controller.dart';
import 'package:pin_lock/src/entities/value_objects.dart';
import 'package:pin_lock/src/repositories/pin_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:pin_lock/src/entities/authenticator.dart';
export 'package:pin_lock/src/entities/lock_controller.dart';
export 'package:pin_lock/src/entities/value_objects.dart';
export 'package:pin_lock/src/presentation/authentication_setup_widget.dart';
export 'package:pin_lock/src/presentation/authenticator_widget.dart';
export 'package:pin_lock/src/presentation/builders.dart';
export 'package:pin_lock/src/presentation/widget_configurations.dart';
export 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';
export 'package:pin_lock/src/repositories/pin_repository.dart';
export 'package:pin_lock/src/entities/failure.dart';
export 'package:pin_lock/src/entities/lock_state.dart';

class PinLock {
  static const MethodChannel _channel = MethodChannel('pin_lock');

  static Future<Authenticator> baseAuthenticator(String userId) async =>
      AuthenticatorImpl(
        LocalAuthenticationRepositoryImpl(
            await SharedPreferences.getInstance()),
        LocalAuthentication(),
        LockController(),
        userId: UserId(userId),
      );
}

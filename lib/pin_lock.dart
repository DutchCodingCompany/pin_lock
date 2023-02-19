import 'dart:async';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/authenticator_impl.dart';
import 'package:pin_lock/src/entities/lock_controller.dart';
import 'package:pin_lock/src/entities/value_objects.dart';
import 'package:pin_lock/src/repositories/pin_repository.dart';
import 'package:pin_lock/src/repositories/pin_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:pin_lock/src/entities/authenticator.dart';
export 'package:pin_lock/src/entities/biometric_availability.dart' show Available, Unavailable;
export 'package:pin_lock/src/entities/biometric_method.dart';
export 'package:pin_lock/src/entities/biometric_availability.dart';
export 'package:pin_lock/src/entities/failure.dart';
export 'package:pin_lock/src/entities/lock_controller.dart';
export 'package:pin_lock/src/entities/lock_state.dart';
export 'package:pin_lock/src/entities/value_objects.dart';
export 'package:pin_lock/src/presentation/authenticator_widget.dart';
export 'package:pin_lock/src/presentation/lock_screen/builders.dart';
export 'package:pin_lock/src/presentation/lock_screen/configurations.dart';
export 'package:pin_lock/src/presentation/pin_input.dart';
export 'package:pin_lock/src/presentation/setup/authentication_setup_widget.dart';
export 'package:pin_lock/src/presentation/setup/configurations.dart';
export 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';
export 'package:pin_lock/src/repositories/pin_repository.dart';
export 'package:pin_lock/src/repositories/pin_repository_impl.dart';

class PinLock {
  PinLock._();
  static const MethodChannel _channel = MethodChannel('pin_lock');

  static void setHideAppContent({
    required bool preference,
    String? iosAssetImage,
  }) {
    _channel.invokeMethod(
      'setHideAppContent',
      {'shouldHide': preference, 'iosAsset': iosAssetImage},
    );
  }

  static Authenticator authenticatorInstance({
    required LocalAuthenticationRepository repository,
    required LocalAuthentication biometricAuthenticator,
    required LockController lockController,
    required UserId userId,
    Duration? lockedOutDuration,
    Duration? lockAfterDuration,
    int? maxRetries,
    int? pinLength,
  }) =>
      AuthenticatorImpl(
        repository,
        biometricAuthenticator,
        lockController,
        maxRetries ?? 5,
        lockedOutDuration ?? const Duration(minutes: 1),
        lockAfterDuration ?? const Duration(seconds: 5),
        pinLength ?? 4,
        userId,
      );

  static Future<Authenticator> baseAuthenticator(String userId) async =>
      PinLock.authenticatorInstance(
        repository: LocalAuthenticationRepositoryImpl(
          await SharedPreferences.getInstance(),
        ),
        biometricAuthenticator: LocalAuthentication(),
        lockController: LockController(),
        userId: UserId(userId),
      );
}

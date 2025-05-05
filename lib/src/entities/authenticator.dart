import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:pin_lock/src/entities/biometric_availability.dart';
import 'package:pin_lock/src/entities/biometric_method.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/lock_state.dart';
import 'package:pin_lock/src/entities/value_objects.dart';

abstract class Authenticator with WidgetsBindingObserver {
  /// Interval after which the app will become pin locked after entering the background
  Duration get lockAfterDuration;

  /// Emits a [PinLockState] event every time the state is changed
  Stream<PinLockState> get lockState;

  /// The number of times that a pin can be entered incorrectly, before the app
  /// stops accepting unlock attempts for [lockedOutDuration]
  int get maxTries;

  /// A duration for which the app will be locked after the number of times the pin is
  /// entered incorrectly exceeds [maxTries]
  Duration get lockedOutDuration;

  /// The expected lenght of the pin, used to draw the [PinInputWidget]
  int get pinLength;

  /// A string value used as a key for storing current user's preferences. Enables multiple users
  /// to use the app on the same device, while preserving unique pin values and preferences of the users
  /// regardless of logging in and out.
  /// If the app is expected to be used by only one user (i.e., there is no login/logout functionality)
  /// this value can be hardcoded ([UserId('1')])
  UserId get userId;

  /// Changes pin of user.
  /// Only happens if [oldPin] is correct and [newPin] matches [newPinConfirmation]
  Future<Either<LocalAuthFailure, Unit>> changePinCode({
    required Pin oldPin,
    required Pin newPin,
    required Pin newPinConfirmation,
  });

  /// Disables locking the app completely, including biometric authentication
  /// Only happens if provided [pin] is correct, or if [force] is true (which should be avoided)
  Future<Either<LocalAuthFailure, Unit>> disableAuthenticationWithPin({
    required Pin pin,
    bool force = false,
  });

  /// Disables biometric authentication. If [requirePin] is true, it is necessary to provide the correct [pin]
  /// before biometric authentication is disabled
  Future<Either<LocalAuthFailure, Unit>> disableBiometricAuthentication({
    bool requirePin = false,
    Pin? pin,
  });

  /// Enables biometric authentication for user.
  Future<Either<LocalAuthFailure, Unit>> enableBiometricAuthentication();

  /// Enables pin authentication, making sure that [pin] and [confirmationPin] match
  Future<Either<LocalAuthFailure, Unit>> enablePinAuthentication({
    required Pin pin,
    required Pin confirmationPin,
  });

  /// [BiometricMethod]s can be used to show the appropriate icons in the UI
  Future<List<BiometricMethod>> getAvailableBiometricMethods();

  /// Checks whether biometric authentication is available on the device and whether the user
  /// has enabled it. If biometric auth is not available, [Unavailable] provides a reason
  Future<BiometricAvailability> getBiometricAuthenticationAvailability();

  /// Returns [true] if the user has a pin set up. A pin has to be set up in order to enable
  /// biometric authentication
  Future<bool> isPinAuthenticationEnabled();

  /// Triggers the OS's biometric authentication and changes the [lockState] if successful
  Future<Either<LocalAuthFailure, Unit>> unlockWithBiometrics({
    required String userFacingExplanation,
  });

  /// Make an attempt to unlock the app using provided [pin]. If the [pin] is correct,
  /// [lockState] will be changed and lock screen dismissed
  Future<Either<LocalAuthFailure, Unit>> unlockWithPin({required Pin pin});

  /// Check if provided [pin] is correct.
  Future<bool> isCorrectPin({required Pin pin});
}

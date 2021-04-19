import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/lock_controller.dart';
import 'package:pin_lock/src/entities/value_objects.dart';
import 'package:pin_lock/src/repositories/pin_repository.dart';
import 'package:local_auth/error_codes.dart' as biometric_error;

// TODO: Should a fallback pin be required?

abstract class Authenticator {
  final int maxRetries;
  final Duration lockedOutDuration;

  LockController get lockController;

  UserId get userId;

  // TODO: Figure out what a constructor should do
  // TODO: Make the authenticator more configurable, with min pin lenght and such
  @mustCallSuper
  const Authenticator({this.maxRetries = 5, this.lockedOutDuration = const Duration(minutes: 5)});

  /// -- Setup --

  /// Returns [true] if the user has pin authentication enabled
  /// It is possible that biometric authentication is not enabled even if pin authentication is
  Future<bool> isPinAuthenticationEnabled();

  /// Returns [true] if the user with id [forUser] has opted in for biometric authentication
  Future<bool> shouldAttemptBiometricAuthentication();

  /// Enables pin authentication, making sure that [pin] and [confirmationPin] match
  Future<Either<LocalAuthFailure, Unit>> enablePinAuthentication({
    required Pin pin,
    required Pin confirmationPin,
  });

  /// Disables locking the app completely, including biometric authentication
  /// Only happens if provided [pin] is correct
  Future<Either<LocalAuthFailure, Unit>> disableAuthenticationWithPin({required Pin pin});

  /// Enables biometric authentication for user.
  /// [Authenticator] will always first attempt to [unlockWithBiometrics]
  // TODO: When checking the lock state and determining that it should be locked, maybe auto-fire unlockWithBiometrics as described above
  Future<Either<LocalAuthFailure, Unit>> enableBiometricAuthentication();

  /// Disables biometric authentication. If [requirePin] is true,
  /// disabling will only happen if the correct [pin] is provided
  Future<Either<LocalAuthFailure, Unit>> disableBiometricAuthentication({
    bool requirePin = false,
    Pin? pin,
  });

  /// Changes pin of user.
  /// Only happens if [oldPin] is correct and [newPin] matches [newPinConfirmation]
  Future<Either<LocalAuthFailure, Unit>> changePinCode({
    required Pin oldPin,
    required Pin newPin,
    required Pin newPinConfirmation,
  });

  /// -- Usage --

  Future<Either<LocalAuthFailure, Unit>> unlockWithPin({required Pin pin});

  /// Triggers the OS's biometric authentication and returns [true] if authentication is successful
  /// [LocalAuthFailure] if it fails
  ///
  Future<Either<LocalAuthFailure, bool>> unlockWithBiometrics({required String userFacingExplanation});

  /// -- Helpers --

  Future<bool> supportsBiometricAuthentication();

  /// [BiometricMethod]s can be used to show the appropriate icons in the UI
  Future<List<BiometricMethod>> getAvailableBiometricMethods();

  // TODO: App in background events + time tracking
}

// TODO: Material app that checks with the [Authenticator] if the screen should be locked

class AuthenticatorImpl implements Authenticator {
  @override
  final Duration lockedOutDuration;

  @override
  final int maxRetries;

  final LocalAuthenticationRepository _repository;
  final LocalAuthentication _biometricAuth;

  @override
  final LockController lockController;

  @override
  final UserId userId;

  AuthenticatorImpl(
    this._repository,
    this._biometricAuth,
    this.lockController, {
    this.maxRetries = 5,
    this.lockedOutDuration = const Duration(minutes: 5),
    required this.userId,
  }) {
    _checkInitialLockStatus();
  }

  Future<void> _checkInitialLockStatus() async {
    final isEnabled = await isPinAuthenticationEnabled();
    if (!isEnabled) {
      lockController.unlock();
    } else {
      final isBiometricsAvailable = await shouldAttemptBiometricAuthentication();
      lockController.lock(isBiometricAvailable: isBiometricsAvailable);
    }
  }

  @override
  Future<bool> isPinAuthenticationEnabled() async {
    final storedValue = await _repository.isPinAuthenticationEnabled(userId: userId);
    return storedValue ?? false;
  }

  @override
  Future<bool> shouldAttemptBiometricAuthentication() async {
    final storedValue = await _repository.isBiometricAuthenticationEnabled(userId: userId);
    return storedValue ?? false;
  }

  /// -- Setup authentication --

  @override
  Future<Either<LocalAuthFailure, Unit>> enablePinAuthentication({
    required Pin pin,
    required Pin confirmationPin,
  }) async {
    final existingPin = await _repository.getPin(forUser: userId);
    if (existingPin != null) {
      return const Left(LocalAuthFailure.alreadySetUp());
    }
    if (pin != confirmationPin) {
      return const Left(LocalAuthFailure.pinNotMatching());
    }
    try {
      await _repository.enableLocalAuthentication(pin: pin, userId: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown());
    }
  }

  @override
  Future<Either<LocalAuthFailure, Unit>> disableAuthenticationWithPin({required Pin pin}) async {
    final isAuthenticationEnabled = await isPinAuthenticationEnabled();
    if (!isAuthenticationEnabled) {
      return const Right(unit);
    }
    final correctPin = await _repository.getPin(forUser: userId);
    if (correctPin?.value != pin.value) {
      return const Left(LocalAuthFailure.wrongPin());
    }
    try {
      await _repository.disableLocalAuthentication(userId: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown());
    }
  }

  @override
  Future<Either<LocalAuthFailure, Unit>> enableBiometricAuthentication() async {
    final isBiometricSupported = await _biometricAuth.canCheckBiometrics;
    if (!isBiometricSupported) {
      return const Left(LocalAuthFailure.notAvailable());
    }
    final availableMethods = await _biometricAuth.getAvailableBiometrics();
    if (availableMethods.isEmpty) {
      return const Left(LocalAuthFailure.notAvailable());
    }

    try {
      await _repository.enableBiometricAuthentication(userId: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown());
    }
  }

  @override
  Future<Either<LocalAuthFailure, Unit>> disableBiometricAuthentication({
    bool requirePin = false,
    Pin? pin,
  }) async {
    final isBiometricsEnabled = await shouldAttemptBiometricAuthentication();
    if (!isBiometricsEnabled) {
      return const Right(unit);
    }
    if (requirePin) {
      final userPin = await _repository.getPin(forUser: userId);
      if (userPin?.value != pin?.value) {
        return const Left(LocalAuthFailure.wrongPin());
      }
    }
    try {
      await _repository.disableBiometricAuthentication(userId: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown());
    }
  }

  // TODO: Is it okay if [newPin] is the same as [oldPin]?
  @override
  Future<Either<LocalAuthFailure, Unit>> changePinCode({
    required Pin oldPin,
    required Pin newPin,
    required Pin newPinConfirmation,
  }) async {
    final isEnabled = await isPinAuthenticationEnabled();
    if (!isEnabled) {
      return const Left(LocalAuthFailure.unknown());
    }
    final unlockAttempt = await unlockWithPin(pin: oldPin);
    if (unlockAttempt.isLeft()) {
      return unlockAttempt;
    }
    if (newPin != newPinConfirmation) {
      return const Left(LocalAuthFailure.pinNotMatching());
    }
    try {
      await _repository.setPin(newPin, forUser: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown());
    }
  }

  /// -- Usage --

  @override
  Future<Either<LocalAuthFailure, Unit>> unlockWithPin({required Pin pin}) async {
    final isEnabled = await isPinAuthenticationEnabled();
    if (!isEnabled) {
      lockController.unlock();
      return const Right(unit);
    }
    final failedAttemptsList = await _repository.getListOfFailedAttempts(userId: userId);
    if (failedAttemptsList.length > maxRetries) {
      // TODO: Return failure and time remaining maybe?
      // TODO: Should it increase the time if more wrong attempts are added?
      return const Left(LocalAuthFailure.tooManyAttempts());
    }

    final userPin = await _repository.getPin(forUser: userId);
    if (userPin?.value != pin.value) {
      await _repository.addFailedAttempt(DateTime.now(), forUser: userId);
      return const Left(LocalAuthFailure.wrongPin());
    }
    if (failedAttemptsList.isNotEmpty) {
      await _repository.resetFailedAttemptCount(ofUser: userId);
    }
    lockController.unlock();
    return const Right(unit);
  }

  @override
  Future<Either<LocalAuthFailure, bool>> unlockWithBiometrics({required String userFacingExplanation}) async {
    final isSupported = await supportsBiometricAuthentication();
    final isEnabled = await shouldAttemptBiometricAuthentication();
    if (!isSupported || !isEnabled) {
      lockController.lock(isBiometricAvailable: false);
      return const Left(LocalAuthFailure.notAvailable());
    }

    try {
      final isSuccessful = await _biometricAuth.authenticate(
        localizedReason: userFacingExplanation,
        stickyAuth: true, // Hopefully this helps when enabling 'fixable' visit to settings
      );
      lockController.unlock();
      return Right(isSuccessful);
    } on PlatformException catch (e) {
      return Left(e.toLocalAuthFailure());
    } catch (e) {
      return const Left(LocalAuthFailure.unknown());
    }
  }

  /// -- Helpers --

  @override
  Future<bool> supportsBiometricAuthentication() {
    return _biometricAuth.isDeviceSupported();
  }

  @override
  Future<List<BiometricMethod>> getAvailableBiometricMethods() async {
    final methods = <BiometricMethod>[];
    final methodsFromLib = await _biometricAuth.getAvailableBiometrics();
    for (final method in methodsFromLib) {
      switch (method) {
        case BiometricType.face:
          methods.add(BiometricMethod.face);
          break;
        case BiometricType.fingerprint:
          methods.add(BiometricMethod.fingerprint);
          break;
        case BiometricType.iris:
          methods.add(BiometricMethod.iris);
          break;
      }
    }
    return methods;
  }
}

extension on PlatformException {
  LocalAuthFailure toLocalAuthFailure() {
    switch (code) {
      case biometric_error.lockedOut:
        return const LocalAuthFailure.tooManyAttempts();
      case biometric_error.permanentlyLockedOut:
        return const LocalAuthFailure.permanentlyLockedOut();
      case biometric_error.notAvailable:
        return const LocalAuthFailure.notAvailable();
      case biometric_error.notEnrolled:
        return const LocalAuthFailure.noFingerprintsAvailable();
      case biometric_error.otherOperatingSystem:
        return const LocalAuthFailure.platformNotSupported();
      default:
        return const LocalAuthFailure.unknown();
    }
  }
}

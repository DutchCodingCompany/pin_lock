import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as biometric_error;
import 'package:local_auth/local_auth.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:pin_lock/src/entities/biometric_availability.dart';

class AuthenticatorImpl with WidgetsBindingObserver implements Authenticator {
  @override
  final Duration lockedOutDuration;
  @override
  final int maxTries;
  @override
  final int pinLength;
  @override
  final Duration lockAfterDuration;

  final LocalAuthenticationRepository _repository;
  final LocalAuthentication _biometricAuth;

  final LockController _lockController;

  AppLifecycleState? _lastState;

  @override
  final UserId userId;

  AuthenticatorImpl(
    this._repository,
    this._biometricAuth,
    this._lockController,
    this.maxTries,
    this.lockedOutDuration,
    this.lockAfterDuration,
    this.pinLength,
    this.userId,
  );

  @override
  Stream<PinLockState> get lockState {
    _checkInitialLockStatus();
    return _lockController.state;
  }

  /// -- WidgetsBindingObserver

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    // don't do anything if pin is disabled
    if (!(await isPinAuthenticationEnabled())) {
      return;
    }

    switch (state) {
      case AppLifecycleState.inactive:

        /// When the app is [paused], it first goes to [inactive] before continuing to [resumed]
        /// Ensure that the paused timestamp is not saved just before the app becomes [resumed]
        if (_lastState != AppLifecycleState.paused) {
          _repository.savePausedTimestamp(DateTime.now());
        }
        break;
      case AppLifecycleState.resumed:

        /// Once app is back in foreground and responding to user input, check if it has been
        /// inactive for more than [lockAfterDuration]
        final lastActive = await _repository.getPausedTimestamp();
        if (lastActive != null) {
          final now = DateTime.now();
          if (now.millisecondsSinceEpoch - lastActive.millisecondsSinceEpoch >
              lockAfterDuration.inMilliseconds) {
            _lockWithBiometricMethods();
          }
        }
        break;
      default:
        break;
    }

    /// Keep track of the last known state
    _lastState = state;
  }

  /// -- Setup authentication --

  @override
  Future<Either<LocalAuthFailure, Unit>> enablePinAuthentication({
    required Pin pin,
    required Pin confirmationPin,
  }) async {
    final existingPin = await _repository.getPin(forUser: userId);
    if (existingPin != null) {
      return const Left(LocalAuthFailure.alreadySetUp);
    }
    if (pin != confirmationPin) {
      return const Left(LocalAuthFailure.pinNotMatching);
    }
    try {
      await _repository.enablePinAuthentication(pin: pin, userId: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown);
    }
  }

  @override
  Future<Either<LocalAuthFailure, Unit>> enableBiometricAuthentication() async {
    final isBiometricSupported = await _biometricAuth.canCheckBiometrics;
    if (!isBiometricSupported) {
      return const Left(LocalAuthFailure.notAvailable);
    }
    final availableMethods = await _biometricAuth.getAvailableBiometrics();
    if (availableMethods.isEmpty) {
      return const Left(LocalAuthFailure.notAvailable);
    }

    try {
      await _repository.enableBiometricAuthentication(userId: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown);
    }
  }

  @override
  Future<Either<LocalAuthFailure, Unit>> disableAuthenticationWithPin({
    required Pin pin,
    bool force = false,
  }) async {
    if (!force) {
      final isAuthenticationEnabled = await isPinAuthenticationEnabled();
      if (!isAuthenticationEnabled) {
        return const Right(unit);
      }
      final correctPin = await _repository.getPin(forUser: userId);
      if (correctPin?.value != pin.value) {
        return const Left(LocalAuthFailure.wrongPin);
      }
    }
    try {
      await _repository.disableLocalAuthentication(userId: userId);
      _lockController.unlock();
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown);
    }
  }

  @override
  Future<Either<LocalAuthFailure, Unit>> disableBiometricAuthentication({
    bool requirePin = false,
    Pin? pin,
  }) async {
    if (requirePin) {
      final userPin = await _repository.getPin(forUser: userId);
      if (userPin?.value != pin?.value) {
        return const Left(LocalAuthFailure.wrongPin);
      }
    }
    try {
      await _repository.disableBiometricAuthentication(userId: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown);
    }
  }

  @override
  Future<Either<LocalAuthFailure, Unit>> changePinCode({
    required Pin oldPin,
    required Pin newPin,
    required Pin newPinConfirmation,
  }) async {
    final isEnabled = await isPinAuthenticationEnabled();
    if (!isEnabled) {
      return const Left(LocalAuthFailure.unknown);
    }
    final unlockAttempt = await unlockWithPin(pin: oldPin);
    if (unlockAttempt.isLeft()) {
      return unlockAttempt;
    }
    if (newPin != newPinConfirmation) {
      return const Left(LocalAuthFailure.pinNotMatching);
    }
    try {
      await _repository.setPin(newPin, forUser: userId);
      return const Right(unit);
    } catch (e) {
      return const Left(LocalAuthFailure.unknown);
    }
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
        case BiometricType.weak:
          methods.add(BiometricMethod.weak);
          break;
        case BiometricType.strong:
          methods.add(BiometricMethod.strong);
          break;
        default:
          break;
      }
    }
    return methods;
  }

  @override
  Future<BiometricAvailability> getBiometricAuthenticationAvailability() async {
    final isSupported = await _supportsBiometricAuthentication();
    if (!isSupported) {
      return const Unavailable(reason: LocalAuthFailure.notAvailable);
    }
    final storedValue = await _repository.isBiometricAuthenticationEnabled(userId: userId);
    return Available(isEnabled: storedValue ?? false);
  }

  @override
  Future<bool> isPinAuthenticationEnabled() async {
    final storedValue = await _repository.isPinAuthenticationEnabled(userId: userId);
    return storedValue ?? false;
  }

  /// -- Usage --

  @override
  Future<Either<LocalAuthFailure, Unit>> unlockWithPin({
    required Pin pin,
  }) async {
    final isEnabled = await isPinAuthenticationEnabled();
    if (!isEnabled) {
      _lockController.unlock();
      return const Right(unit);
    }
    if (await _isLockedDueToTooManyAttempts()) {
      return const Left(LocalAuthFailure.tooManyAttempts);
    }

    final userPin = await _repository.getPin(forUser: userId);
    if (userPin?.value != pin.value) {
      await _repository.addFailedAttempt(DateTime.now(), forUser: userId);
      if (await _isLockedDueToTooManyAttempts()) {
        return const Left(LocalAuthFailure.tooManyAttempts);
      }
      return const Left(LocalAuthFailure.wrongPin);
    }
    await _repository.resetFailedAttempts(ofUser: userId);
    _lockController.unlock();
    _repository.clearLastPausedTimestamp();
    return const Right(unit);
  }

  @override
  Future<Either<LocalAuthFailure, Unit>> unlockWithBiometrics({
    required String userFacingExplanation,
  }) async {
    final biometricAvailability = await getBiometricAuthenticationAvailability();
    if (biometricAvailability is Available) {
      if (!biometricAvailability.isEnabled) {
        _lockController.lock(availableMethods: const []);
        return const Left(LocalAuthFailure.notAvailable);
      }
      if (await _isLockedDueToTooManyAttempts()) {
        return const Left(LocalAuthFailure.tooManyAttempts);
      }

      try {
        final isSuccessful = await _biometricAuth.authenticate(
          localizedReason: userFacingExplanation,
          options: const AuthenticationOptions(biometricOnly: true),
        );
        if (isSuccessful) {
          _lockController.unlock();
          return const Right(unit);
        }
        return const Left(LocalAuthFailure.biometricAuthenticationFailed);
      } on PlatformException catch (e) {
        return Left(e.toLocalAuthFailure());
      } catch (e) {
        return const Left(LocalAuthFailure.unknown);
      }
    }
    if (biometricAvailability is Unavailable) {
      _lockController.lock(availableMethods: const []);
      return const Left(LocalAuthFailure.notAvailable);
    }
    return const Left(LocalAuthFailure.unknown);
  }

  @override
  Future<bool> isCorrectPin({required Pin pin}) async {
    final isEnabled = await isPinAuthenticationEnabled();
    if (!isEnabled) {
      return true;
    }
    if (await _isLockedDueToTooManyAttempts()) {
      return false;
    }

    final userPin = await _repository.getPin(forUser: userId);
    if (userPin?.value != pin.value) {
      await _repository.addFailedAttempt(DateTime.now(), forUser: userId);
      if (await _isLockedDueToTooManyAttempts()) {
        return false;
      }
      return false;
    }
    await _repository.resetFailedAttempts(ofUser: userId);
    _repository.clearLastPausedTimestamp();
    return true;
  }

  /// -- Helpers --

  Future<bool> _supportsBiometricAuthentication() {
    return _biometricAuth.isDeviceSupported();
  }

  Future<bool> _isLockedDueToTooManyAttempts() async {
    final failedAttemptsList = await _repository.getListOfFailedAttempts(userId: userId);
    if (failedAttemptsList.length >= maxTries) {
      if (DateTime.now().difference(failedAttemptsList.last) < lockedOutDuration) {
        return true;
      }
    }
    return false;
  }

  Future<void> _checkInitialLockStatus() async {
    final isEnabled = await isPinAuthenticationEnabled();
    if (!isEnabled) {
      _lockController.unlock();
    } else {
      _lockWithBiometricMethods();
    }
  }

  Future<void> _lockWithBiometricMethods() async {
    final biometric = await getBiometricAuthenticationAvailability();
    if (biometric is Available) {
      _lockController.lock(
        availableMethods: biometric.isEnabled
            ? await getAvailableBiometricMethods()
            : const [],
      );
    }
    if (biometric is Unavailable) {
      _lockController.lock(availableMethods: const []);
    }
  }
}

extension on PlatformException {
  LocalAuthFailure toLocalAuthFailure() {
    switch (code) {
      case biometric_error.lockedOut:
        return LocalAuthFailure.tooManyAttempts;
      case biometric_error.permanentlyLockedOut:
        return LocalAuthFailure.permanentlyLockedOut;
      case biometric_error.notAvailable:
        return LocalAuthFailure.notAvailable;
      case biometric_error.notEnrolled:
        return LocalAuthFailure.noFingerprintsAvailable;
      case biometric_error.otherOperatingSystem:
        return LocalAuthFailure.platformNotSupported;
      default:
        return LocalAuthFailure.unknown;
    }
  }
}

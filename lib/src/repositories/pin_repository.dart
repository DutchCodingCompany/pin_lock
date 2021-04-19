import 'package:pin_lock/src/entities/value_objects.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalAuthenticationRepository {
  /// Used to determine if the lock screen should be shown
  Future<bool?> isPinAuthenticationEnabled({required UserId userId});

  /// User's preference of if they want to use biometric authentication
  Future<bool?> isBiometricAuthenticationEnabled({required UserId userId});

  /// Writes to the repository the user's preference to have local authentication enabled
  /// with the given [pin], for the user with [userId]
  Future<void> enableLocalAuthentication({required Pin pin, required UserId userId});

  Future<void> enableBiometricAuthentication({required UserId userId});

  /// Writes to the repository the preference of the user with [userId] to not show lock screen
  /// Makes [isAuthenticationEnabled()] return false
  Future<void> disableLocalAuthentication({required UserId userId});

  /// Disables only biometric authentication
  /// To also disable pin authentication, use [disableLocalAuthentication]
  Future<void> disableBiometricAuthentication({required UserId userId});

  /// Returns the [Pin] of the user with [forUser] id, or [null] if no [Pin] is set
  Future<PinHash?> getPin({required UserId forUser});

  /// Set the [newPin] for user with [forUser] id
  Future<void> setPin(Pin newPin, {required UserId forUser});

  /// Gets a list of [DateTime] timestamps of all the previous failed attempts
  Future<List<DateTime>> getListOfFailedAttempts({required UserId userId});

  /// Adds [timestamp] to the list of failed attempts of user with [forUser] id
  Future<void> addFailedAttempt(DateTime timestamp, {required UserId forUser});

  /// Clears the list of failed attempts [ofUser]
  Future<void> resetFailedAttemptCount({required UserId ofUser});
}

class LocalAuthenticationRepositoryImpl implements LocalAuthenticationRepository {
  final SharedPreferences sp;

  LocalAuthenticationRepositoryImpl(this.sp);

  SPKey _keyBoolPinEnabled(UserId userId) => SPKey('pin_enabled$userId');
  SPKey _keyBoolBiometricsEnabled(UserId userId) => SPKey('biometric_enabled$userId');
  SPKey _keyStringPin(UserId userId) => SPKey('pin$userId');
  SPKey _keyListFailedAttempts(UserId userId) => SPKey('failed_attempts$userId');

  @override
  Future<bool?> isPinAuthenticationEnabled({required UserId userId}) async {
    try {
      return sp.getBool(_keyBoolPinEnabled(userId).value);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool?> isBiometricAuthenticationEnabled({required UserId userId}) async {
    try {
      return sp.getBool(_keyBoolBiometricsEnabled(userId).value);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> enableLocalAuthentication({required Pin pin, required UserId userId}) async {
    sp.setBool(_keyBoolPinEnabled(userId).value, true);
    sp.setString(_keyStringPin(userId).value, pin.value);
  }

  @override
  Future<void> enableBiometricAuthentication({required UserId userId}) async {
    sp.setBool(_keyBoolBiometricsEnabled(userId).value, true);
  }

  @override
  Future<void> disableLocalAuthentication({required UserId userId}) async {
    sp.setBool(_keyBoolPinEnabled(userId).value, false);
    sp.remove(_keyStringPin(userId).value);
  }

  @override
  Future<void> disableBiometricAuthentication({required UserId userId}) async {
    sp.setBool(_keyBoolBiometricsEnabled(userId).value, false);
  }

  @override
  Future<PinHash?> getPin({required UserId forUser}) async {
    final pinHash = sp.getString(_keyStringPin(forUser).value);
    if (pinHash != null) {
      return PinHash(pinHash);
    }
    return null;
  }

  @override
  Future<void> setPin(Pin newPin, {required UserId forUser}) async {
    await enableLocalAuthentication(pin: newPin, userId: forUser);
  }

  @override
  Future<List<DateTime>> getListOfFailedAttempts({required UserId userId}) async {
    final list = sp.getStringList(_keyListFailedAttempts(userId).value);
    if (list == null) {
      return <DateTime>[];
    }
    return list.map((e) => DateTime.parse(e)).toList();
  }

  @override
  Future<void> addFailedAttempt(DateTime timestamp, {required UserId forUser}) async {
    final key = _keyListFailedAttempts(forUser).value;
    final list = sp.getStringList(key);
    if (list == null) {
      sp.setStringList(key, [timestamp.toString()]);
    } else {
      sp.setStringList(key, [...list, timestamp.toString()]);
    }
  }

  @override
  Future<void> resetFailedAttemptCount({required UserId ofUser}) async {
    sp.remove(_keyListFailedAttempts(ofUser).value);
  }
}

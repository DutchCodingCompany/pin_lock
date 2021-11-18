import 'package:pin_lock/pin_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthenticationRepositoryImpl implements LocalAuthenticationRepository {
  final SharedPreferences sp;

  LocalAuthenticationRepositoryImpl(this.sp);

  SPKey _keyBoolPinEnabled(UserId userId) => SPKey('pin_enabled$userId');
  SPKey _keyBoolBiometricsEnabled(UserId userId) => SPKey('biometric_enabled$userId');
  SPKey _keyStringPin(UserId userId) => SPKey('pin$userId');
  SPKey _keyListFailedAttempts(UserId userId) => SPKey('failed_attempts$userId');

  static const String _keyPausedTimestamp = 'key_paused';

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
  Future<void> enablePinAuthentication({required Pin pin, required UserId userId}) async {
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
    await enablePinAuthentication(pin: newPin, userId: forUser);
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
  Future<void> resetFailedAttempts({required UserId ofUser}) async {
    sp.remove(_keyListFailedAttempts(ofUser).value);
  }

  @override
  Future<void> savePausedTimestamp(DateTime time) async {
    await sp.setString(_keyPausedTimestamp, time.toString());
  }

  @override
  Future<void> clearLastPausedTimestamp() async {
    await sp.remove(_keyPausedTimestamp);
  }

  @override
  Future<DateTime?> getPausedTimestamp() async {
    final dateString = sp.getString(_keyPausedTimestamp);
    if (dateString != null) {
      final date = DateTime.tryParse(dateString);
      return date;
    }
    return null;
  }
}

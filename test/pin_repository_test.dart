import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pin_repository_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late SharedPreferences sharedPreferences;

  late LocalAuthenticationRepositoryImpl repository;

  setUp(() {
    sharedPreferences = MockSharedPreferences();
    repository = LocalAuthenticationRepositoryImpl(sharedPreferences);
  });

  group('isPinAuthenticationEnabled', () {
    test('returns true when true in SP', () async {
      final key = SPKey('pin_enabled${UserId("1")}').value;
      when(sharedPreferences.getBool(key)).thenAnswer((_) => true);
      final answer =
          await repository.isPinAuthenticationEnabled(userId: UserId('1'));
      expect(answer, true);
    });

    test('returns false when false in SP', () async {
      final key = SPKey('pin_enabled${UserId("1")}').value;
      when(sharedPreferences.getBool(key)).thenAnswer((_) => false);
      final answer =
          await repository.isPinAuthenticationEnabled(userId: UserId('1'));
      expect(answer, false);
    });

    test('returns null when null in SP', () async {
      final key = SPKey('pin_enabled${UserId("1")}').value;
      when(sharedPreferences.getBool(key)).thenAnswer((_) => null);
      final answer =
          await repository.isPinAuthenticationEnabled(userId: UserId('1'));
      expect(answer, null);
    });

    test('returns null if reading from SP fails', () async {
      final key = SPKey('pin_enabled${UserId("1")}').value;
      when(sharedPreferences.getBool(key))
          .thenThrow((_) => Exception('something went wrong'));
      final answer =
          await repository.isPinAuthenticationEnabled(userId: UserId('1'));
      expect(answer, null);
    });
  });

  group('isBiometricAuthenticationEnabled', () {
    test('returns true when true in SP', () async {
      final key = SPKey('biometric_enabled${UserId("1")}').value;
      when(sharedPreferences.getBool(key)).thenAnswer((_) => true);
      final answer = await repository.isBiometricAuthenticationEnabled(
        userId: UserId('1'),
      );
      expect(answer, true);
    });

    test('returns false when false in SP', () async {
      final key = SPKey('biometric_enabled${UserId("1")}').value;
      when(sharedPreferences.getBool(key)).thenAnswer((_) => false);
      final answer = await repository.isBiometricAuthenticationEnabled(
        userId: UserId('1'),
      );
      expect(answer, false);
    });

    test('returns null when null in SP', () async {
      final key = SPKey('biometric_enabled${UserId("1")}').value;
      when(sharedPreferences.getBool(key)).thenAnswer((_) => null);
      final answer = await repository.isBiometricAuthenticationEnabled(
        userId: UserId('1'),
      );
      expect(answer, null);
    });

    test('returns null if reading from SP fails', () async {
      final key = SPKey('biometric_enabled${UserId("1")}').value;
      when(sharedPreferences.getBool(key))
          .thenThrow((_) => Exception('something went wrong'));
      final answer = await repository.isBiometricAuthenticationEnabled(
        userId: UserId('1'),
      );
      expect(answer, null);
    });
  });

  group('enable/disable pin auth', () {
    test('enableLocalAuthentication', () {
      final user = UserId('1');
      final boolKey = SPKey('pin_enabled$user').value;
      final pinKey = SPKey('pin$user');
      final pin = Pin('1234');
      when(sharedPreferences.setBool(boolKey, true))
          .thenAnswer((_) async => true);
      when(sharedPreferences.setString(pinKey.value, pin.value))
          .thenAnswer((_) async => true);
      repository.enablePinAuthentication(pin: pin, userId: user);
      verify(sharedPreferences.setBool(boolKey, true));
      verify(sharedPreferences.setString(pinKey.value, pin.value));
    });
    test('disableLocalAuthentication', () {
      final user = UserId('1');
      final boolKey = SPKey('pin_enabled$user').value;
      final pinKey = SPKey('pin$user');
      when(sharedPreferences.setBool(boolKey, false))
          .thenAnswer((_) async => true);
      when(sharedPreferences.remove(pinKey.value))
          .thenAnswer((_) async => true);
      repository.disableLocalAuthentication(userId: user);
      verify(sharedPreferences.setBool(boolKey, false));
      verify(sharedPreferences.remove(pinKey.value));
    });
  });

  group('enable/disable biometric auth', () {
    test('enableBiometricAuthentication', () {
      final user = UserId('1');
      final boolKey = SPKey('biometric_enabled$user').value;
      when(sharedPreferences.setBool(boolKey, true))
          .thenAnswer((_) async => true);
      repository.enableBiometricAuthentication(userId: user);
      verify(sharedPreferences.setBool(boolKey, true));
    });
    test('disableBiometricAuthentication', () {
      final user = UserId('1');
      final boolKey = SPKey('biometric_enabled$user').value;
      when(sharedPreferences.setBool(boolKey, false))
          .thenAnswer((_) async => true);
      repository.disableBiometricAuthentication(userId: user);
      verify(sharedPreferences.setBool(boolKey, false));
    });
  });

  group('getPin', () {
    test('returns null if no pin is set', () async {
      final user = UserId('1');
      final key = SPKey('pin$user').value;
      when(sharedPreferences.getString(key)).thenAnswer((_) => null);
      final pin = await repository.getPin(forUser: user);
      expect(pin, null);
    });

    test('return pin hash', () async {
      final user = UserId('1');
      final key = SPKey('pin$user').value;
      when(sharedPreferences.getString(key)).thenAnswer((_) => '1111');
      final pin = await repository.getPin(forUser: user);
      expect(pin, const PinHash('1111'));
    });
  });

  group('setPin', () {
    test('writes relevant values to SP', () {
      final user = UserId('1');
      final boolKey = SPKey('pin_enabled$user').value;
      final pinKey = SPKey('pin$user');
      final pin = Pin('1234');
      when(sharedPreferences.setBool(boolKey, true))
          .thenAnswer((_) async => true);
      when(sharedPreferences.setString(pinKey.value, pin.value))
          .thenAnswer((_) async => true);
      repository.setPin(pin, forUser: user);
      verify(sharedPreferences.setBool(boolKey, true));
      verify(sharedPreferences.setString(pinKey.value, pin.value));
    });
  });

  group('failed attempts', () {
    // TODO: Finish writing tests
  });
}

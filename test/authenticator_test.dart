import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/lock_controller.dart';
import 'package:pin_lock/src/entities/value_objects.dart';
import 'package:pin_lock/src/repositories/pin_repository.dart';

import 'authenticator_test.mocks.dart';

@GenerateMocks([LocalAuthenticationRepository, LocalAuthentication, LockController])
void main() {
  late MockLocalAuthenticationRepository repository;
  late MockLocalAuthentication localAuth;
  late LockController lockController;

  late Authenticator authenticator;

  setUp(() {
    localAuth = MockLocalAuthentication();
    repository = MockLocalAuthenticationRepository();
    lockController = MockLockController();
    when(lockController.unlock()).thenReturn(null);
    when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((realInvocation) async => true);
    when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((realInvocation) async => true);
    authenticator = AuthenticatorImpl(repository, localAuth, lockController, userId: UserId('1'));
  });

  group('isPinAuthenticationEnabled()', () {
    test('returns true if it is set in the repository', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));

      final response = await authenticator.isPinAuthenticationEnabled();
      expect(response, true);
    });

    test('returns false if set in the repository', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(false));

      final response = await authenticator.isPinAuthenticationEnabled();
      expect(response, false);
    });
    test('returns false if not set in the repository', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(null));

      final response = await authenticator.isPinAuthenticationEnabled();
      expect(response, false);
    });
  });

  group('shouldAttemptBiometricAuthentication', () {
    test('returns true if it is set in the repository', () async {
      when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));

      final response = await authenticator.shouldAttemptBiometricAuthentication();
      expect(response, true);
    });

    test('returns false if set in the repository', () async {
      when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(false));

      final response = await authenticator.shouldAttemptBiometricAuthentication();
      expect(response, false);
    });
    test('returns false if not set in the repository', () async {
      when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(null));

      final response = await authenticator.shouldAttemptBiometricAuthentication();
      expect(response, false);
    });
  });

  group('enablePinAuthentication', () {
    test('fails with [LocalAuthFailure.alreadySetUp] if there is an existing pin', () async {
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) => Future.value(PinHash(Pin('1').value)));
      final result = await authenticator.enablePinAuthentication(
        pin: Pin('1'),
        confirmationPin: Pin('2'),
      );
      expect(result, const Left(AlreadySetUp()));
    });
    test('returns [LocalAuthFailure.pinNotMatching] if confirmation pin does not match the new pin', () async {
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) => Future.value(null));
      final result = await authenticator.enablePinAuthentication(
        pin: Pin('1'),
        confirmationPin: Pin('2'),
      );
      expect(result, const Left(PinNotMatching()));
    });
    test('fails with [LocalAuthFailure.unknown] if the repository throws an error', () async {
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) => Future.value(null));
      when(repository.enableLocalAuthentication(pin: Pin('1'), userId: UserId('1'))).thenThrow(Exception());
      final result = await authenticator.enablePinAuthentication(
        pin: Pin('1'),
        confirmationPin: Pin('1'),
      );
      verify(repository.enableLocalAuthentication(pin: Pin('1'), userId: UserId('1')));
      expect(result, const Left(Unknown()));
    });

    test(
        'calls enableLocalAuthentication() on repository with appropriate parameters if all data is correct and returns [unit]',
        () async {
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) => Future.value(null));
      final result = await authenticator.enablePinAuthentication(
        pin: Pin('1'),
        confirmationPin: Pin('1'),
      );
      verify(repository.enableLocalAuthentication(pin: Pin('1'), userId: UserId('1')));
      expect(result, const Right(unit));
    });
  });

  group('disablePinAuthentication', () {
    test('auto-succeeds (returns unit) if pin authentication is not enabled', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(false));

      final result = await authenticator.disableAuthenticationWithPin(pin: Pin('2'));
      expect(result, const Right(unit));
    });

    test('fails with [LocalAuthFailure.wrongPin] if wrong pin is provided', () async {
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => Future.value(PinHash(Pin('1').value)));
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));

      final result = await authenticator.disableAuthenticationWithPin(pin: Pin('2'));
      expect(result, const Left(WrongPin()));
    });

    test('fails with [.unknown] if repository throws', () async {
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => Future.value(PinHash(Pin('1').value)));
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));
      when(repository.disableLocalAuthentication(userId: UserId('1'))).thenThrow(Exception());

      final result = await authenticator.disableAuthenticationWithPin(pin: Pin('1'));
      expect(result, const Left(Unknown()));
    });

    test('succeeds and returns unit if all parameters are correct', () async {
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => Future.value(PinHash(Pin('1').value)));
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));

      final result = await authenticator.disableAuthenticationWithPin(pin: Pin('1'));
      expect(result, const Right(unit));
    });
  });
  group('enableBiometricAuthentication', () {
    test('fails with [LocalAuthFailure.notAvailable if biometrics cannot be checked', () async {
      when(localAuth.getAvailableBiometrics()).thenAnswer((_) => Future.value([]));
      when(localAuth.canCheckBiometrics).thenAnswer((_) => Future.value(false));

      final result = await authenticator.enableBiometricAuthentication();

      expect(result, const Left(NotAvailable()));
    });

    test('fails with [LocalAuthFailure.notAvailable if no available biometric methods', () async {
      when(localAuth.getAvailableBiometrics()).thenAnswer((_) => Future.value([]));
      when(localAuth.canCheckBiometrics).thenAnswer((_) => Future.value(true));

      final result = await authenticator.enableBiometricAuthentication();

      expect(result, const Left(NotAvailable()));
    });

    test('fails with [LocalAuthFailure.unknown] if the repository throws an error', () async {
      when(localAuth.getAvailableBiometrics()).thenAnswer((_) => Future.value([BiometricType.face]));
      when(localAuth.canCheckBiometrics).thenAnswer((_) => Future.value(true));
      when(repository.enableBiometricAuthentication(userId: UserId('1'))).thenThrow(Exception());

      final result = await authenticator.enableBiometricAuthentication();
      verify(repository.enableBiometricAuthentication(userId: UserId('1')));
      expect(result, const Left(Unknown()));
    });

    test('calls enableBiometricAuthentication() in repository with correct UserId and returns [unit]', () async {
      when(localAuth.getAvailableBiometrics()).thenAnswer((_) => Future.value([BiometricType.face]));
      when(localAuth.canCheckBiometrics).thenAnswer((_) => Future.value(true));

      final result = await authenticator.enableBiometricAuthentication();
      verify(repository.enableBiometricAuthentication(userId: UserId('1')));
      expect(result, const Right(unit));
    });
  });

  group('disableBiometricAuthentication', () {
    test('auto-succeeds (returns unit) if biometric authentication is not enabled', () async {
      when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(false));

      final result = await authenticator.disableBiometricAuthentication(pin: Pin('2'));
      expect(result, const Right(unit));
    });

    group('with pinRequired', () {
      test('incorrect pin: fails with [.wrongPin]', () async {
        when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('1').value));
        when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) async => true);

        final result = await authenticator.disableBiometricAuthentication(
          requirePin: true,
          pin: Pin('2'),
        );
        expect(result, const Left(WrongPin()));
      });
      test('correct pin: fails with [.unknown] if the repository throws', () async {
        when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('1').value));
        when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) async => true);

        when(repository.disableBiometricAuthentication(userId: UserId('1'))).thenThrow(Exception());

        final result = await authenticator.disableBiometricAuthentication(
          requirePin: true,
          pin: Pin('1'),
        );
        expect(result, const Left(Unknown()));
      });

      test('correct pin: calls disableBiometricAuthentication() in repository and returns unit', () async {
        when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('1').value));
        when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) async => true);

        final result = await authenticator.disableBiometricAuthentication(
          requirePin: true,
          pin: Pin('1'),
        );

        verify(repository.disableBiometricAuthentication(userId: UserId('1')));
        expect(result, const Right(unit));
      });
    });

    group('without pinRequired', () {
      test('fails with [.unknown] if the repository throws', () async {
        when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));
        when(repository.disableBiometricAuthentication(userId: UserId('1'))).thenThrow(Exception());

        final result = await authenticator.disableBiometricAuthentication();
        expect(result, const Left(Unknown()));
      });

      test('calls disableBiometricAuthentication() in repository and returns unit', () async {
        when(repository.isBiometricAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));

        final result = await authenticator.disableBiometricAuthentication();
        verify(repository.disableBiometricAuthentication(userId: UserId('1')));
        expect(result, const Right(unit));
      });
    });
  });

  group('changePinCode', () {
    test('fails with [.unknown] if pin authentication is not enabled', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(false));

      final result = await authenticator.changePinCode(
        oldPin: Pin('1'),
        newPin: Pin('2'),
        newPinConfirmation: Pin('2'),
      );

      expect(result, const Left(Unknown()));
    });
    test('fails with [.wrongPin] if oldPin is incorrect', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) async => true);
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer((_) async => const []);
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('2').value));

      final result = await authenticator.changePinCode(
        oldPin: Pin('1'),
        newPin: Pin('2'),
        newPinConfirmation: Pin('2'),
      );

      expect(result, const Left(WrongPin()));
    });
    test('fails with [.tooManyAttempts] if maxRetries is exceeded', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) async => true);
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer(
        (_) async => List.generate(10, (index) => DateTime.now()),
      );

      final result = await authenticator.changePinCode(
        oldPin: Pin('1'),
        newPin: Pin('2'),
        newPinConfirmation: Pin('2'),
      );

      expect(result, const Left(TooManyAttempts()));
    });

    test('fails with [.pinNotMatching] if [newPin] is different from [newPinConfirmation]', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) async => true);
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer((_) async => const []);
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('1').value));

      final result = await authenticator.changePinCode(
        oldPin: Pin('1'),
        newPin: Pin('2'),
        newPinConfirmation: Pin('3'),
      );

      expect(result, const Left(PinNotMatching()));
    });

    test('fails with [.unknown] if repository throws while writing the new pin', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) async => true);
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer((_) async => const []);
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('1').value));
      when(repository.setPin(Pin('2'), forUser: UserId('1'))).thenThrow(Exception());

      final result = await authenticator.changePinCode(
        oldPin: Pin('1'),
        newPin: Pin('2'),
        newPinConfirmation: Pin('2'),
      );

      expect(result, const Left(Unknown()));
    });

    test('writes new pin to the repository and returns unit if all parameters are correct', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) async => true);
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer((_) async => const []);
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('1').value));

      final result = await authenticator.changePinCode(
        oldPin: Pin('1'),
        newPin: Pin('2'),
        newPinConfirmation: Pin('2'),
      );

      verify(repository.setPin(Pin('2'), forUser: UserId('1')));
      expect(result, const Right(unit));
    });
  });

  group('unlockWithPin', () {
    // TODO: verify that lock controller has been notified
    test('auto-succeeds if pin authentication is not enabled', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(false));
      final result = await authenticator.unlockWithPin(pin: Pin('1'));
      verify(lockController.unlock());
      expect(result, const Right(unit));
    });

    test('fails with [.tooManyAttempts] if maxRetries has been exceeded', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer(
        (_) async => List.generate(6, (index) => DateTime.now()),
      );
      final result = await authenticator.unlockWithPin(pin: Pin('1'));
      expect(result, const Left(TooManyAttempts()));
    });

    test('fails with [.wrongPin] if a wrong pin was provided', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer(
        (_) async => List.generate(2, (index) => DateTime.now()),
      );
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('2').value));

      final result = await authenticator.unlockWithPin(pin: Pin('1'));
      expect(result, const Left(WrongPin()));
    });

    test('increments failed attempts and fails with [.wrongPin] if a wrong pin was provided', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer(
        (_) async => List.generate(2, (index) => DateTime.now()),
      );
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('2').value));

      final result = await authenticator.unlockWithPin(pin: Pin('1'));

      verify(repository.addFailedAttempt(any, forUser: UserId('1')));
      expect(result, const Left(WrongPin()));
    });

    test('succeeds if a correct pin was provided and unlocks the LockController', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer(
        (_) async => List.generate(2, (index) => DateTime.now()),
      );
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('1').value));

      final result = await authenticator.unlockWithPin(pin: Pin('1'));
      verify(lockController.unlock());
      expect(result, const Right(unit));
    });

    test('resets failed attempt count and succeeds if a correct pin was provided', () async {
      when(repository.isPinAuthenticationEnabled(userId: UserId('1'))).thenAnswer((_) => Future.value(true));
      when(repository.getListOfFailedAttempts(userId: UserId('1'))).thenAnswer(
        (_) async => List.generate(2, (index) => DateTime.now()),
      );
      when(repository.getPin(forUser: UserId('1'))).thenAnswer((_) async => PinHash(Pin('1').value));

      final result = await authenticator.unlockWithPin(pin: Pin('1'));
      verify(repository.resetFailedAttemptCount(ofUser: UserId('1')));
      expect(result, const Right(unit));
    });
  });
}

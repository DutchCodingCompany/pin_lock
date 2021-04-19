import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
class LocalAuthFailure with _$LocalAuthFailure {
  /// Indicates that the user has not yet configured a passcode (iOS) or
  /// PIN/pattern/password (Android) on the device.
  const factory LocalAuthFailure.passcodeNotSet() = PasscodeNotSet;

  /// Indicates the user has not enrolled any fingerprints on the device.
  const factory LocalAuthFailure.noFingerprintsAvailable() = NoFingerprintsAvailable;

  /// Indicates the API being disabled due to too many lock outs.
  const factory LocalAuthFailure.tooManyAttempts() = TooManyAttempts;

  /// Strong authentication like PIN/Pattern/Password is required to unlock.
  const factory LocalAuthFailure.permanentlyLockedOut() = PermanentlyLockedOut;

  /// Indicates the device operating system is not iOS or Android.
  const factory LocalAuthFailure.platformNotSupported() = PlatformNotSupported;

  /// Indicates the device does not have a Touch ID/fingerprint scanner.
  const factory LocalAuthFailure.notAvailable() = NotAvailable;

  /// Provided PIN code was wrong
  const factory LocalAuthFailure.wrongPin() = WrongPin;

  /// PIN and confirmation PIN don't match
  const factory LocalAuthFailure.pinNotMatching() = PinNotMatching;

  /// Biometric authentication failed without providing any other reason
  const factory LocalAuthFailure.biometricAuthenticationFailed() = BiometricAuthenticationFailed;

  /// Authentication is already set up, overwriting is not allowed
  const factory LocalAuthFailure.alreadySetUp() = AlreadySetUp;

  /// Authentication failed for no specific reason
  const factory LocalAuthFailure.unknown() = Unknown;
}

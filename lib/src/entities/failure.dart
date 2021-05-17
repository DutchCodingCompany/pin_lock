enum LocalAuthFailure {
  /// Indicates that the user has not yet configured a passcode (iOS) or
  /// PIN/pattern/password (Android) on the device.
  passcodeNotSet,

  /// Indicates the user has not enrolled any fingerprints on the device.
  noFingerprintsAvailable,

  /// Indicates the API being disabled due to too many lock outs.
  tooManyAttempts,

  /// Strong authentication like PIN/Pattern/Password is required to unlock.
  permanentlyLockedOut,

  /// Indicates the device operating system is not iOS or Android.
  platformNotSupported,

  /// Indicates the device does not have a Touch ID/fingerprint scanner.
  notAvailable,

  /// Provided PIN code was wrong
  wrongPin,

  /// PIN and confirmation PIN don't match
  pinNotMatching,

  /// Biometric authentication failed without providing any other reason
  biometricAuthenticationFailed,

  /// Authentication is already set up, overwriting is not allowed
  alreadySetUp,

  /// Authentication failed for no specific reason
  unknown,
}

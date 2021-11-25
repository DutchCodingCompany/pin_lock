import 'package:pin_lock/src/entities/value_objects.dart';

/// Used to store values between sessions. [pin_lock] comes with [SharedPreferences](https://pub.dev/packages/shared_preferences)
/// implementation out of the box, but it is possible to provide your own implementation (e.g., using encrypted storage library
/// instead) by implementing [LocalAuthenticationRepository] interface and passing it to [Authenticator.instance()]
abstract class LocalAuthenticationRepository {
  /// Used to determine if the lock screen should be shown
  Future<bool?> isPinAuthenticationEnabled({required UserId userId});

  /// User's preference of if they want to use biometric authentication
  Future<bool?> isBiometricAuthenticationEnabled({required UserId userId});

  /// Writes to the repository the user's preference to have local authentication enabled
  /// with the given [pin], for the user with [userId]
  Future<void> enablePinAuthentication(
      {required Pin pin, required UserId userId});

  Future<void> enableBiometricAuthentication({required UserId userId});

  /// Writes to the repository the preference of the user with [userId] to not show lock screen
  /// This includes both pin and biometric authentication
  Future<void> disableLocalAuthentication({required UserId userId});

  /// Disables only biometric authentication, while keeping the pin.
  /// To also disable pin authentication, use [disableLocalAuthentication]
  Future<void> disableBiometricAuthentication({required UserId userId});

  /// Returns the [PinHash] of the user with [forUser] id, or [null] if no pin is set
  Future<PinHash?> getPin({required UserId forUser});

  /// Set the [newPin] for user with [forUser] id
  Future<void> setPin(Pin newPin, {required UserId forUser});

  /// Gets a list of [DateTime] timestamps of all the previous failed authentication attempts
  /// (i.e., times when a wrong pincode was entered)
  Future<List<DateTime>> getListOfFailedAttempts({required UserId userId});

  /// Adds [timestamp] to the list of failed authentication attempts of user with [forUser] id
  Future<void> addFailedAttempt(DateTime timestamp, {required UserId forUser});

  /// Clears the list of failed authentication attempts [ofUser]
  Future<void> resetFailedAttempts({required UserId ofUser});

  /// Saves the timestamp when the app became paused (i.e., lost focus), so that the
  /// app could be locked if the user has been away from it for longer than [Authenticator.lockAfterDuration]
  Future<void> savePausedTimestamp(DateTime time);

  /// Get timestamp of when the app became paused to determine if sufficient time has passed for it to be locked
  Future<DateTime?> getPausedTimestamp();

  /// Clear the last paused timestamp, e.g., when the app has been successfully unlocked
  Future<void> clearLastPausedTimestamp();
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pin_lock/pin_lock.dart';

/// Provides information needed to draw the Lock Screen, such as the pin input widget
/// that needs to be placed on the LockScreen and available biometric methods that
/// can be used to draw a correct icon on biometric authentication button
class LockScreenConfiguration extends Equatable {
  /// A widget through which the user can enter their pincode to authenticate
  /// Conforms to the looks specified by [PinInputBuilder]
  final Widget pinInputWidget;

  /// Whether authentication is a loading state, e.g., while checking
  /// if the provided pin is correct
  final bool isLoading;

  /// Returns a list of available authentication methods, which can be used to draw
  /// a correct icon on the lock screen (e.g., touch ID vs face ID icon).
  /// If the device has no biometric authentication capabilites, or if the user has not
  /// previously enabled biometric authentication, the returned list is empty.
  final List<BiometricMethod> availableBiometricMethods;

  /// Triggers native OS biometric authentication. Should be passed as the `onClick`
  /// parameter to the 'unlock with biometrics' button
  final VoidCallback onBiometricAuthenticationRequested;

  /// Provides a reason for the error that occured, making it possible to display
  /// an appropriate error message to the user
  final LocalAuthFailure? error;

  const LockScreenConfiguration({
    required this.pinInputWidget,
    required this.isLoading,
    required this.error,
    required this.availableBiometricMethods,
    required this.onBiometricAuthenticationRequested,
  });

  @override
  List<Object?> get props => [
        pinInputWidget,
        isLoading,
        error,
        availableBiometricMethods,
        onBiometricAuthenticationRequested,
      ];
}

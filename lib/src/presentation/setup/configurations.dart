import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:pin_lock/src/entities/failure.dart';

/// Provides information necessary to draw a screen with
/// the overview of the current state of local authentication (e.g.,
/// whether pin is enabled and whether the device has biometric
/// authentication capabilities), as well as the callbacks used to make
/// the screen interactive (e.g., requesting password change)
class OverviewConfiguration extends Equatable {
  /// [true] if pin authentication data is still being fetched from local storage
  final bool isLoading;

  /// Whether the user has set up pin authentication. Can be [null] if data is still loading,
  /// (i.e., when [isLoading] is true)
  final bool? isPinEnabled;

  /// Whether the given device has biometric authentication capabilities. Used to potentially
  /// not display biometric authentication information to users who can't make use of it.
  /// Can be [null] if data is still being fetched, regardless of the value of [isLoading]
  final bool? isBiometricAuthAvailable;

  /// Returns [true] only if both the user has opted in for the biometric authentication and
  /// the device has biometric authentication capabilities. Can be [null] if data is still being
  /// retrieved, regardless of the value of [isLoading]
  final bool? isBiometricAuthEnabled;

  /// A callback notifying [Authenticator] that the user has requested a change in
  /// their pin settings (either to enable it if disabled, or vice versa).
  /// Can be invoked manually, but it was originally intended to be
  /// passed as `onClick` property to a button or a switch on the overview screen
  final VoidCallback onTogglePin;

  /// A callback notifying [Authenticator] that the user has requested a pin change.
  /// Can be invoked manually, but it is intended to be passed as the `onClick`
  /// to a "change password" button
  final VoidCallback onPasswordChangeRequested;

  /// A callback notifying [Authenticator] that the user wants to enable or disable
  /// biometric authentication. Can be passed as the `onClick` parameter to a
  /// "toggle biometrics button". Triggering this callback when [isBiometricAuthAvailable]
  /// results in an appropriate [LocalAuthFailure] error
  final VoidCallback onToggleBiometric;

  /// Provides a reason for the error that occured, which makes it possible to display
  /// an apporpriate message to the user
  final LocalAuthFailure? error;

  /// Optionally re-check the state of local authentication, e.g., by passing this callback
  /// to the refresh function of pull-to-refres
  final VoidCallback onRefresh;

  const OverviewConfiguration({
    required this.isPinEnabled,
    required this.isBiometricAuthAvailable,
    required this.isBiometricAuthEnabled,
    required this.onTogglePin,
    required this.onPasswordChangeRequested,
    required this.isLoading,
    required this.onToggleBiometric,
    required this.error,
    required this.onRefresh,
  });

  @override
  List<Object?> get props => [
        isLoading,
        isPinEnabled,
        isBiometricAuthAvailable,
        isBiometricAuthEnabled,
        onTogglePin,
        onPasswordChangeRequested,
        onToggleBiometric,
        error,
        onRefresh,
      ];
}

/// Provides information necessary for drawing a screen through which the user
/// sets up their pin
class EnablingPinConfiguration extends Equatable {
  /// A widget that conforms to the look provided by [PinInputBuilder]. It should be
  /// placed on the screen according to the app's designs
  final Widget pinInputWidget;

  /// A widget that enables user to re-enter their pin to confirm that the inital pin is
  /// entered correctly. Conforms to the look provided by [PinInputBuilder] and should be placed
  /// on the enabling pin screen according to the designs of the app
  final Widget pinConfirmationWidget;

  /// Can optionally be used to controll whether the 'submit' or 'save' button is visible or enabled.
  /// If [onSubmitChange] is triggered while [canSubmitChange] is [false], it will result in
  /// an [error] in the configuration
  final bool canSubmitChange;

  /// A callback that notifies the [Authenticator] that the user wants to save their changes.
  /// If the pins don't match or they are too short, the next [EnablingPinConfiguration] will
  /// contain an appropriate [error]
  final VoidCallback onSubmitChange;

  /// A callback that reverts the state of the [AuthenticationSetupWidget] to Overview state. Intended to be used
  /// as the `onClick` parameter of a 'cancel' button
  final VoidCallback onCancel;

  /// Provides a reason for the error that occured, which makes it possible to display
  /// an apporpriate message to the user
  final LocalAuthFailure? error;

  const EnablingPinConfiguration({
    this.error,
    required this.pinInputWidget,
    required this.pinConfirmationWidget,
    required this.canSubmitChange,
    required this.onSubmitChange,
    required this.onCancel,
  });

  @override
  List<Object?> get props => [
        error,
        pinInputWidget,
        pinConfirmationWidget,
        canSubmitChange,
        onSubmitChange,
        onCancel,
      ];
}

/// Provides information necessary to draw the screen through which the user can disable the pin that
/// they have already set up before. It requires the correct pin to be entered in order to disable it.
class DisablingPinConfiguration extends Equatable {
  /// A widget that conforms to the look provided by [PinInputBuilder].
  /// The user must enter their current pin in order to disable it.
  /// It should be placed on the screen according to the app's designs
  final Widget pinInputWidget;

  /// Can optionally be used to controll whether the 'submit' or 'save' button is visible or enabled.
  /// If [onChangeSubmitted] is triggered while [canSubmitChange] is [false], it will result in
  /// an [error] in the configuration
  final bool canSubmitChange;

  /// A callback that notifies the [Authenticator] that the user wants to attempt to disable pincode.
  /// If a wrong pincode is entered, it results in an [error]
  final VoidCallback onChangeSubmitted;

  /// A callback that reverts the state of the [AuthenticationSetupWidget] to Overview state. Intended to be used
  /// as the `onClick` parameter of a 'cancel' button
  final VoidCallback onCancel;

  /// Provides a reason for the error that occured, which makes it possible to display
  /// an apporpriate message to the user
  final LocalAuthFailure? error;

  const DisablingPinConfiguration(
      {this.error,
      required this.pinInputWidget,
      required this.canSubmitChange,
      required this.onChangeSubmitted,
      required this.onCancel});
  @override
  List<Object?> get props => [
        error,
        pinInputWidget,
        canSubmitChange,
        onChangeSubmitted,
        onCancel,
      ];
}

/// Provides information needed to draw a screen through which the user can
/// change their password
class ChangingPinConfiguration extends Equatable {
  /// A widget through which the user inputs the pin that they want to change.
  /// Providing the existing pin is necessary to be able to change it to something else
  final Widget oldPinInputWidget;

  /// A widget through which the user inputs their new pin.
  final Widget newPinInputWidget;

  /// A widget through which the user re-enters their desired pin, making sure that it
  /// matches the input of [newPinInputWidget]
  final Widget confirmNewPinInputWidget;

  /// Can optionally be used to controll whether the 'submit' or 'save' button is visible or enabled.
  /// If [onSubmitChange] is triggered while [canSubmitChange] is [false], it will result in
  /// an [error] in the configuration
  final bool canSubmitChange;

  /// A callback that notifies the [Authenticator] that the user wants to attempt to change their pin.
  /// The most common [error]s that can result from this are [LocalAuthFailure.wrongPin] if the existing pin
  /// is incorrently entered or [LocalAuthFailure.pinNotMatching] if the new pin and confirmation pin are not
  /// identical
  final VoidCallback onSubimtChange;

  /// A callback that reverts the state of the [AuthenticationSetupWidget] to Overview state. Intended to be used
  /// as the `onClick` parameter of a 'cancel' button
  final VoidCallback onCancel;

  /// Provides a reason for the error that occured, which makes it possible to display
  /// an apporpriate message to the user
  final LocalAuthFailure? error;

  const ChangingPinConfiguration({
    required this.oldPinInputWidget,
    required this.newPinInputWidget,
    required this.confirmNewPinInputWidget,
    required this.error,
    required this.canSubmitChange,
    required this.onSubimtChange,
    required this.onCancel,
  });

  @override
  List<Object?> get props => [
        oldPinInputWidget,
        newPinInputWidget,
        confirmNewPinInputWidget,
        error,
        canSubmitChange,
        onSubimtChange,
        onCancel,
      ];
}

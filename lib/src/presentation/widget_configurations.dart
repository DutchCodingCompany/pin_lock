import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/value_objects.dart';

class OverviewConfiguration extends Equatable {
  final bool isLoading;
  final bool? isPinEnabled;
  final bool? isBiometricAuthAvailable;
  final bool? isBiometricAuthEnabled;
  final VoidCallback onTogglePin;
  final VoidCallback onPasswordChangeRequested;
  final VoidCallback onToggleBiometric;
  final LocalAuthFailure? error;
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

class EnablingPinConfiguration extends Equatable {
  final LocalAuthFailure? error;
  final Widget pinInputWidget;
  final Widget pinConfirmationWidget;
  final bool canSubmitChange;
  final VoidCallback onSubmitChange;
  final VoidCallback onCancel;

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

class DisablingPinConfiguration extends Equatable {
  final LocalAuthFailure? error;
  final Widget pinInputWidget;
  final bool canSubmitChange;
  final VoidCallback onChangeSubmitted;
  final VoidCallback onCancel;

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

class ChangingPinConfiguration extends Equatable {
  final Widget oldPinInputWidget;
  final Widget newPinInputWidget;
  final Widget confirmNewPinInputWidget;
  final LocalAuthFailure? error;
  final bool canSubmitChange;
  final VoidCallback onSubimtChange;
  final VoidCallback onCancel;

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

class LockScreenConfiguration extends Equatable {
  final Widget pinInputWidget;
  final bool isLoading;
  final LocalAuthFailure? error;
  final List<BiometricMethod> availableBiometricMethods;
  final VoidCallback onBiometricAuthenticationRequested;

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

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_lock/src/entities/failure.dart';

class OverviewConfiguration extends Equatable {
  final bool isLoading;
  final bool? isPinEnabled;
  final bool? isBiometricAuthAvailable;
  final bool? isBiometricAuthEnabled;
  final VoidCallback onTogglePin;
  final VoidCallback onPasswordChangeRequested;

  const OverviewConfiguration({
    required this.isPinEnabled,
    required this.isBiometricAuthAvailable,
    required this.isBiometricAuthEnabled,
    required this.onTogglePin,
    required this.onPasswordChangeRequested,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [
        isPinEnabled,
        isBiometricAuthAvailable,
        isBiometricAuthEnabled,
        onTogglePin,
        onPasswordChangeRequested,
      ];
}

class EnablingPinConfiguration extends Equatable {
  final LocalAuthFailure? error;
  final Widget pinInputWidget;
  final Widget pinConfirmationWidget;
  final bool canSubmitChange;
  final VoidCallback onSubmitChange;

  const EnablingPinConfiguration({
    this.error,
    required this.pinInputWidget,
    required this.pinConfirmationWidget,
    required this.canSubmitChange,
    required this.onSubmitChange,
  });

  @override
  List<Object?> get props => [
        error,
        pinInputWidget,
        pinConfirmationWidget,
        canSubmitChange,
        onSubmitChange,
      ];
}

class DisablingPinConfiguration extends Equatable {
  final LocalAuthFailure? error;
  final Widget pinInputWidget;
  final bool canSubmitChange;
  final VoidCallback onChangeSubmitted;

  const DisablingPinConfiguration({
    this.error,
    required this.pinInputWidget,
    required this.canSubmitChange,
    required this.onChangeSubmitted,
  });
  @override
  List<Object?> get props => [error, pinInputWidget, canSubmitChange, onChangeSubmitted];
}

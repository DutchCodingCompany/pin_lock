import 'package:equatable/equatable.dart';
import 'package:pin_lock/src/entities/failure.dart';

abstract class SetupStage extends Equatable {
  LocalAuthFailure? get error;
  bool canGoFurther(int pinLength);

  const SetupStage();

  @override
  List<Object?> get props => [];
}

class Base extends SetupStage {
  final bool isLoading;
  final bool? isPinAuthEnabled;
  final bool? isBiometricAuthAvailable;
  final bool? isBiometricAuthEnabled;
  @override
  final LocalAuthFailure? error;

  const Base({
    this.isLoading = false,
    this.isPinAuthEnabled,
    this.isBiometricAuthAvailable,
    this.isBiometricAuthEnabled,
    this.error,
  });

  @override
  bool canGoFurther(int pinLength) => true;

  @override
  List<Object?> get props => [isLoading, isPinAuthEnabled, isBiometricAuthAvailable, isBiometricAuthEnabled, error];

  Base copyWith({
    bool? isLoading,
    bool? isPinAuthEnabled,
    bool? isBiometricAuthEnabled,
    bool? isBiometricAuthAvailable,
    LocalAuthFailure? error,
  }) =>
      Base(
        isLoading: isLoading ?? this.isLoading,
        isPinAuthEnabled: isPinAuthEnabled ?? this.isPinAuthEnabled,
        isBiometricAuthEnabled: isBiometricAuthEnabled ?? this.isBiometricAuthEnabled,
        isBiometricAuthAvailable: isBiometricAuthAvailable ?? this.isBiometricAuthAvailable,
        error: error,
      );
}

class Enabling extends SetupStage {
  final String? pin;
  final String? confirmationPin;
  @override
  final LocalAuthFailure? error;

  const Enabling({
    this.pin,
    this.confirmationPin,
    this.error,
  });

  @override
  bool canGoFurther(int pinLength) => pin?.length == pinLength && confirmationPin?.length == pinLength;

  @override
  List<Object?> get props => [pin, confirmationPin, error];

  Enabling copyWith({
    String? pin,
    String? confirmationPin,
    int? pinLength,
    LocalAuthFailure? error,
  }) =>
      Enabling(
        pin: pin ?? this.pin,
        confirmationPin: confirmationPin ?? this.confirmationPin,
        error: error,
      );
}

class Disabling extends SetupStage {
  final String pin;
  @override
  final LocalAuthFailure? error;

  const Disabling({this.pin = '', this.error});

  @override
  bool canGoFurther(int pinLength) => pinLength == pin.length;

  @override
  List<Object?> get props => [pin, error];

  Disabling copyWith({int? pinLength, String? pin, LocalAuthFailure? error}) => Disabling(
        pin: pin ?? this.pin,
        error: error,
      );
}

class ChangingPasscode extends SetupStage {
  final String currentPin;
  final String confirmationPin;
  final String newPin;
  @override
  final LocalAuthFailure? error;

  const ChangingPasscode({
    this.currentPin = '',
    this.confirmationPin = '',
    this.newPin = '',
    this.error,
  });

  @override
  bool canGoFurther(int pinLength) =>
      currentPin.length == pinLength && newPin.length == pinLength && confirmationPin.length == pinLength;

  @override
  List<Object?> get props => [currentPin, confirmationPin, newPin, error];

  ChangingPasscode copyWith({
    int? pinLength,
    String? currentPin,
    String? confirmationPin,
    String? newPin,
    LocalAuthFailure? error,
  }) =>
      ChangingPasscode(
        currentPin: currentPin ?? this.currentPin,
        confirmationPin: confirmationPin ?? this.confirmationPin,
        newPin: newPin ?? this.newPin,
        error: error,
      );
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pin_lock/src/entities/failure.dart';

part 'setup_stage.freezed.dart';

@freezed
class SetupStage with _$SetupStage {
  const SetupStage._();
  const factory SetupStage.base({
    @Default(false) bool isLoading,
    bool? isPinAuthEnabled,
    bool? isBiometricAuthAvailable,
    bool? isBiometricAuthEnabled,
  }) = Base;

  const factory SetupStage.enabling({
    String? pin,
    String? confirmationPin,
    required int pinLength,
    LocalAuthFailure? error,
  }) = Enabling;

  const factory SetupStage.disabling({
    required int pinLength,
    @Default('') String pin,
    LocalAuthFailure? error,
  }) = Disabling;

  const factory SetupStage.changingPasscode({
    required int pinLength,
    @Default('') String currentPin,
    @Default('') String newPin,
    @Default('') String confirmationPin,
    LocalAuthFailure? error,
  }) = ChangingPasscode;

  bool get canGoFurther => map(
        base: (_) => true,
        enabling: (s) => s.pin?.length == s.pinLength && s.confirmationPin?.length == s.pinLength,
        disabling: (s) => s.pinLength == s.pin.length,
        changingPasscode: (s) =>
            s.currentPin.length == s.pinLength &&
            s.newPin.length == s.pinLength &&
            s.confirmationPin.length == s.pinLength,
      );
}

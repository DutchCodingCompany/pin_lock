import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/blocs/cubit/setup_stage.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/biometric_availability.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/value_objects.dart';

class SetuplocalauthCubit extends Cubit<SetupStage> {
  final Authenticator authenticator;
  SetuplocalauthCubit(this.authenticator) : super(const Base(isLoading: true));

  Future<void> checkInitialState() async {
    final lastState = state;
    if (lastState is Base) {
      final isPinAuthEnabled = await authenticator.isPinAuthenticationEnabled();
      emit(lastState.copyWith(
          isPinAuthEnabled: isPinAuthEnabled, isLoading: false));

      if (!isPinAuthEnabled) {
        emit(lastState.copyWith(
          isBiometricAuthAvailable: false,
          isBiometricAuthEnabled: false,
          isLoading: false,
          isPinAuthEnabled: isPinAuthEnabled,
        ));
        return;
      }

      final biometrics =
          await authenticator.getBiometricAuthenticationAvailability();
      if (biometrics is Available) {
        emit(lastState.copyWith(
          isPinAuthEnabled: isPinAuthEnabled,
          isBiometricAuthAvailable: true,
          isBiometricAuthEnabled: biometrics.isEnabled,
          isLoading: false,
        ));
      }
      if (biometrics is Unavailable) {
        emit(lastState.copyWith(
          isPinAuthEnabled: isPinAuthEnabled,
          isBiometricAuthEnabled: false,
          isBiometricAuthAvailable: false,
          isLoading: false,
        ));
      }
    } else {
      emit(const Base(isLoading: true));
      checkInitialState();
    }
  }

  Future<void> toggleBiometricAuthentication() async {
    final lastState = state;
    if (lastState is Base) {
      final biometricAvailability =
          await authenticator.getBiometricAuthenticationAvailability();
      if (biometricAvailability is Available) {
        final result = biometricAvailability.isEnabled
            ? await authenticator.disableBiometricAuthentication()
            : await authenticator.enableBiometricAuthentication();
        result.fold((l) => emit(lastState.copyWith(error: l)),
            (r) => checkInitialState());
      }
    }
  }

  Future<void> startEnablingPincode() async {
    emit(const Enabling());
  }

  void pinEntered(String pin) {
    final lastState = state;
    if (lastState is Enabling) {
      emit(lastState.copyWith(pin: pin));
    }
  }

  void pinConfirmationEntered(String confirmation) {
    final lastState = state;
    if (lastState is Enabling) {
      emit(lastState.copyWith(confirmationPin: confirmation));
    }
  }

  Future<void> savePin() async {
    final lastState = state;
    if (lastState is Enabling) {
      final response = await authenticator.enablePinAuthentication(
        pin: Pin(lastState.pin ?? ''),
        confirmationPin: Pin(lastState.confirmationPin ?? ''),
      );
      response.fold(
        (l) {
          emit(
            lastState.copyWith(
              error: l,
              confirmationPin: l == LocalAuthFailure.pinNotMatching ? '' : null,
            ),
          );
        },
        (r) {
          emit(const Base(isLoading: true));
          checkInitialState();
        },
      );
    }
  }

  void startDisablingPincode() {
    emit(const Disabling());
  }

  void enterPinToDisable(String pin) {
    final lastState = state;
    if (lastState is Disabling) {
      emit(lastState.copyWith(pin: pin));
    }
  }

  Future<void> disablePinAuthentication() async {
    final lastState = state;
    if (lastState is Disabling) {
      final result = await authenticator.disableAuthenticationWithPin(
          pin: Pin(lastState.pin));
      result.fold(
        (l) => emit(lastState.copyWith(pin: '', error: l)),
        (r) => checkInitialState(),
      );
    }
  }

  void startChangingPincode() {
    emit(const ChangingPasscode());
  }

  void enterPinToChange(String pin) {
    final lastState = state;
    if (lastState is ChangingPasscode) {
      emit(lastState.copyWith(currentPin: pin));
    }
  }

  void enterNewPin(String pin) {
    final lastState = state;
    if (lastState is ChangingPasscode) {
      emit(lastState.copyWith(newPin: pin));
    }
  }

  void enterConfirmationPin(String pin) {
    final lastState = state;
    if (lastState is ChangingPasscode) {
      emit(lastState.copyWith(confirmationPin: pin));
    }
  }

  Future<void> changePin() async {
    final lastState = state;
    if (lastState is ChangingPasscode) {
      final result = await authenticator.changePinCode(
        oldPin: Pin(lastState.currentPin),
        newPin: Pin(lastState.newPin),
        newPinConfirmation: Pin(lastState.confirmationPin),
      );
      result.fold(
        (l) {
          switch (l) {
            case LocalAuthFailure.tooManyAttempts:
              emit(lastState.copyWith(currentPin: '', error: l));
              break;
            case LocalAuthFailure.wrongPin:
              emit(lastState.copyWith(currentPin: '', error: l));
              break;
            case LocalAuthFailure.pinNotMatching:
              emit(lastState.copyWith(
                newPin: '',
                confirmationPin: '',
                error: l,
              ));
              break;
            default:
              emit(lastState.copyWith(error: l));
          }
        },
        (r) => checkInitialState(),
      );
    }
  }
}

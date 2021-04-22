import 'package:bloc/bloc.dart';
import 'package:pin_lock/src/blocs/cubit/setup_stage.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/value_objects.dart';

class SetuplocalauthCubit extends Cubit<SetupStage> {
  final Authenticator authenticator;
  SetuplocalauthCubit(this.authenticator) : super(const Base(isLoading: true));

  Future<void> checkInitialState() async {
    final lastState = state;
    if (lastState is Base) {
      final isPinAuthEnabled = await authenticator.isPinAuthenticationEnabled();
      emit(lastState.copyWith(isPinAuthEnabled: isPinAuthEnabled, isLoading: false));

      final biometrics = await authenticator.getBiometricAuthenticationAvailability();
      biometrics.when(
        available: (isEnabled) {
          emit(lastState.copyWith(
            isPinAuthEnabled: isPinAuthEnabled,
            isBiometricAuthAvailable: true,
            isBiometricAuthEnabled: isEnabled,
            isLoading: false,
          ));
        },
        unavailable: (_) {
          emit(lastState.copyWith(
            isPinAuthEnabled: isPinAuthEnabled,
            isBiometricAuthEnabled: false,
            isBiometricAuthAvailable: false,
            isLoading: false,
          ));
        },
      );
    } else {
      emit(const Base(isLoading: true));
      checkInitialState();
    }
  }

  Future<void> startEnablingPincode() async {
    emit(Enabling(pinLength: authenticator.pinLength));
  }

  void pinEntered(String pin) {
    final lastState = state;
    if (lastState is Enabling) {
      final canSave = authenticator.isValidPin(pin) && authenticator.isValidPin(lastState.confirmationPin ?? '');
      emit(lastState.copyWith(pin: pin, canSave: canSave));
    }
  }

  void pinConfirmationEntered(String confirmation) {
    final lastState = state;
    if (lastState is Enabling) {
      final canSave = authenticator.isValidPin(confirmation) && authenticator.isValidPin(lastState.pin ?? '');
      emit(lastState.copyWith(confirmationPin: confirmation, canSave: canSave));
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
        (l) => emit(lastState.copyWith(error: l)),
        (r) {
          emit(const Base(isLoading: true));
          checkInitialState();
        },
      );
    }
  }

  void startDisablingPincode() {
    emit(Disabling(pinLength: authenticator.pinLength));
  }

  void enterPinToDisable(String pin) {
    final lastState = state;
    if (lastState is Disabling) {
      emit(lastState.copyWith(pin: pin, canUnlock: authenticator.isValidPin(pin)));
    }
  }

  Future<void> disablePinAuthentication() async {
    final lastState = state;
    if (lastState is Disabling) {
      final result = await authenticator.disableAuthenticationWithPin(pin: Pin(lastState.pin));
      result.fold(
        (l) => emit(lastState.copyWith(pin: '', canUnlock: false, error: l)),
        (r) => checkInitialState(),
      );
    }
  }
}

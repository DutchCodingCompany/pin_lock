import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/value_objects.dart';

class LockCubit extends Cubit<LockScreenState> {
  final Authenticator _authenticator;
  LockCubit(this._authenticator) : super(const LockScreenState(isLoading: true));

  Future<void> enterPin(String pin) async {
    emit(LockScreenState(pin: pin));
    if (_authenticator.isValidPin(pin)) {
      final result = await _authenticator.unlockWithPin(pin: Pin(pin));
      result.fold(
        (l) => emit(LockScreenState(error: l)),
        (r) => null,
      );
    }
  }
}

class LockScreenState extends Equatable {
  final bool isLoading;
  final String pin;
  final LocalAuthFailure? error;

  const LockScreenState({this.isLoading = false, this.pin = '', this.error});

  @override
  List<Object?> get props => [isLoading, pin, error];
}

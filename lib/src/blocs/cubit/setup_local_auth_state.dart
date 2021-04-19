part of 'setup_local_auth_cubit.dart';

abstract class SetupLocalAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class Loading extends SetupLocalAuthState {}

class Enabling extends SetupLocalAuthState {
  Enabling(this.pin, this.confirmationPin, this.error);

  final Pin pin;
  final Pin confirmationPin;
  final LocalAuthFailure? error;

  @override
  List<Object?> get props => [pin, confirmationPin, error];
}

class Disabling extends SetupLocalAuthState {}

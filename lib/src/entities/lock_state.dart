import 'package:equatable/equatable.dart';
import 'package:pin_lock/pin_lock.dart';

abstract class LockState extends Equatable {
  const LockState();
  @override
  List<Object?> get props => [];
}

class Locked extends LockState {
  final List<BiometricMethod> availableBiometricMethods;

  const Locked({required this.availableBiometricMethods});

  @override
  List<Object?> get props => [availableBiometricMethods];
}

class Unlocked extends LockState {
  const Unlocked() : super();
}

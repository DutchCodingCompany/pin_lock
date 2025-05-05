import 'package:equatable/equatable.dart';
import 'package:pin_lock/src/entities/biometric_method.dart';

abstract class PinLockState extends Equatable {
  const PinLockState();
  @override
  List<Object?> get props => [];
}

class Locked extends PinLockState {
  final List<BiometricMethod> availableBiometricMethods;

  const Locked({required this.availableBiometricMethods});

  @override
  List<Object?> get props => [availableBiometricMethods];
}

class Unlocked extends PinLockState {
  const Unlocked() : super();
}

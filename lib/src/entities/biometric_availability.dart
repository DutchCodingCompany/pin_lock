import 'package:equatable/equatable.dart';
import 'package:pin_lock/src/entities/failure.dart';

abstract class BiometricAvailability extends Equatable {
  const BiometricAvailability();
  @override
  List<Object?> get props => [];
}

class Available extends BiometricAvailability {
  final bool isEnabled;

  const Available({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class Unavailable extends BiometricAvailability {
  final LocalAuthFailure reason;

  const Unavailable({required this.reason});
  @override
  List<Object?> get props => [reason];
}

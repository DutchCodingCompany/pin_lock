import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pin_lock/src/entities/failure.dart';

part 'biometric_availability.freezed.dart';

@freezed
class BiometricAvailability with _$BiometricAvailability {
  const factory BiometricAvailability.available({required bool isEnabled}) = Available;
  const factory BiometricAvailability.unavailable({required LocalAuthFailure reason}) = Unavailable;
}

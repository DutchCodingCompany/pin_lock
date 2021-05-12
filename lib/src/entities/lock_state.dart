import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pin_lock/pin_lock.dart';

part 'lock_state.freezed.dart';

@freezed
class LockState with _$LockState {
  const factory LockState.unlocked() = Unlocked;
  const factory LockState.locked({required List<BiometricMethod> availableBiometricMethods}) = Locked;
}

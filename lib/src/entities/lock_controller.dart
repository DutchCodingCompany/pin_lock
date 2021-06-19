import 'dart:async';

import 'package:pin_lock/src/entities/biometric_method.dart';
import 'package:pin_lock/src/entities/lock_state.dart';

class LockController {
  late final Stream<LockState> state;
  final StreamController<LockState> _streamController;

  LockController() : _streamController = StreamController.broadcast() {
    state = _streamController.stream;
  }

  void lock({required List<BiometricMethod> availableMethods}) {
    _streamController.add(Locked(availableBiometricMethods: availableMethods));
  }

  void unlock() {
    _streamController.add(const Unlocked());
  }
}

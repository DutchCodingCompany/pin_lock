import 'dart:async';

import 'package:pin_lock/src/entities/lock_state.dart';

class LockController {
  late final Stream<LockState> state;
  final StreamController<LockState> _streamController;

  LockController() : _streamController = StreamController.broadcast() {
    state = _streamController.stream;
  }

  void lock({required bool isBiometricAvailable}) {
    _streamController.add(Locked(isBiometricAvailable: isBiometricAvailable));
  }

  void unlock() {
    _streamController.add(const Unlocked());
  }
}

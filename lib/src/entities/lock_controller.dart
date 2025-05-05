import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pin_lock/src/entities/biometric_method.dart';
import 'package:pin_lock/src/entities/lock_state.dart';

/// Keeps track of the lock state of the app while it's active.
/// It allows registering callbacks that will get triggered when the
/// app is locked/unlocked (e.g., for analytics purposes)
class LockController {
  /// The stream of [PinLockState] where the last entry is always the current
  /// state of the app
  late final Stream<PinLockState> state;

  /// Optionally register a callback that gets triggered every time the app is locked
  /// (e.g., for analytics purposes)
  final VoidCallback? onLockCallback;

  /// Optionally register a callback that gets triggered every time the app is unlocked
  /// (e.g., for analytics purposes)
  final VoidCallback? onUnlockCallback;

  final StreamController<PinLockState> _streamController;

  LockController({this.onUnlockCallback, this.onLockCallback})
      : _streamController = StreamController.broadcast() {
    state = _streamController.stream;
  }

  /// Results in displaying lock screen overlay. Intended to be triggered by the [Authenticator], but could
  /// also be triggered manually, i.e., from your application's code. In case there's a need to trigger the
  /// lock screen manually, keep in mind that this will create a non-dismissable overlay that can only be
  /// removed by authenticating with the correct pin / biometrics. For this reason it is important to
  /// **never trigger [lock] method manually if authentication is not enabled**.
  /// Triggering the lock screen manually will not persist accross sessions.
  /// [availableMethods] refer to [BiometricMethod]s that the device supports, or an empty list if the
  /// device doesn't support biometrics or the user has not opted in to using it.
  void lock({required List<BiometricMethod> availableMethods}) {
    _streamController.add(Locked(availableBiometricMethods: availableMethods));
  }

  /// Results in dismissing the lock screen overlay and making the app contents visible.
  /// Probably shouldn't be used manually, unless there's a really good reason to. It was
  /// intended to be used by the pin_lock package internally
  void unlock() {
    _streamController.add(const Unlocked());
  }
}

import 'package:flutter/material.dart';
import 'package:pin_lock/src/presentation/lock_screen/configurations.dart';

/// Descibes the UI of the lock screen given the [LockScreenConfiguration]
typedef LockScreenBuilder = Widget Function(
    LockScreenConfiguration configuration);

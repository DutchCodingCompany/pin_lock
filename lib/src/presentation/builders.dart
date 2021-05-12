import 'package:flutter/material.dart';
import 'package:pin_lock/src/presentation/widget_configurations.dart';

typedef OverviewBuilder = Widget Function(OverviewConfiguration configuration);
typedef EnablingPinWidgetBuilder = Widget Function(EnablingPinConfiguration configuration);
typedef DisablingPinWidgetBuilder = Widget Function(DisablingPinConfiguration configuration);

enum InputFieldState { empty, focused, filled }
typedef PinInputBuilder = Widget Function(int index, InputFieldState state);

typedef LockScreenBuilder = Widget Function(LockScreenConfiguration configuration);

typedef SplashScreenBuilder = Widget Function();

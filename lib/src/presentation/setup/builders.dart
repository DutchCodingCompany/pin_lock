import 'package:flutter/material.dart';
import 'package:pin_lock/src/presentation/setup/configurations.dart';

/// Builds UI based on given [OverviewConfiguration]
typedef OverviewBuilder = Widget Function(OverviewConfiguration configuration);

/// Builds UI based on given [EnablingPinConfiguration]
typedef EnablingPinWidgetBuilder = Widget Function(
    EnablingPinConfiguration configuration);

/// Builds UI based on given [DisablingPinConfiguration]
typedef DisablingPinWidgetBuilder = Widget Function(
    DisablingPinConfiguration configuration);

/// Builds UI based on given [ChangingPinConfiguration]
typedef ChangingPinWidgetBuilder = Widget Function(
    ChangingPinConfiguration configuration);

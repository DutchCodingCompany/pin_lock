import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:pin_lock/src/blocs/cubit/lock_cubit.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/biometric_method.dart';
import 'package:pin_lock/src/entities/lock_state.dart';
import 'package:pin_lock/src/presentation/lock_screen/builders.dart';
import 'package:pin_lock/src/presentation/lock_screen/configurations.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

/// Root widget of the part of the app that needs to be protected by the pin.
/// Takes the app's [Authenticator] as a parameter and makes sure that a lock
/// screen is shown as a non-dismissable overlay when the app should be locked.
class AuthenticatorWidget extends StatefulWidget {
  /// The app's [Authenticator]. Make sure there's only one per app, otherwise
  /// the locking functionality might not work reliably
  final Authenticator authenticator;

  /// The part of the application that should be locked behind the pin screen
  final Widget child;

  /// Describes what the lock screen should look like, given the [LockScreenConfiguration].
  final LockScreenBuilder lockScreenBuilder;

  /// Optional description of the splash screen. This should be used if you deliberately want
  /// to delay the appearance of the lock screen so that your users could see the splash screen.
  /// It only adds a Dart-side "splash", the native splash screens need to be implemented
  /// manually in your app.
  final SplashScreenBuilder? splashScreenBuilder;

  /// Optional duration for which to delay the appearance of the lock screen.
  /// You shouldn't be adding unecessary delays to your application, but sometimes
  /// the designs require it :/
  final Duration splashScreenDuration;

  /// The message that the user sees in a native dialog while attempting to unlock
  /// the app using biometric authentication
  final String userFacingBiometricAuthenticationMessage;

  /// Describes what an individual pin input field is going to look like, given its
  //// position ([index]) and its [InputFieldState]
  final PinInputBuilder inputNodeBuilder;

  const AuthenticatorWidget({
    Key? key,
    required this.authenticator,
    required this.child,
    required this.lockScreenBuilder,
    required this.userFacingBiometricAuthenticationMessage,
    required this.inputNodeBuilder,
    this.splashScreenBuilder,
    this.splashScreenDuration = const Duration(),
  }) : super(key: key);

  @override
  _AuthenticatorWidgetState createState() => _AuthenticatorWidgetState();
}

class _AuthenticatorWidgetState extends State<AuthenticatorWidget> {
  late final StreamSubscription lockSubscription;
  OverlayEntry? overlayEntry;
  bool _isShowingSplashScreen = true;

  @override
  void initState() {
    super.initState();
    lockSubscription = widget.authenticator.lockState.listen((event) {
      if (event is Unlocked) {
        overlayEntry?.remove();
        overlayEntry = null;
      }
      if (event is Locked) {
        if (overlayEntry == null) {
          overlayEntry = OverlayEntry(
            opaque: true,
            builder: (context) => _LockScreen(
              authenticator: widget.authenticator,
              builder: widget.lockScreenBuilder,
              inputNodeBuilder: widget.inputNodeBuilder,
              availableMethods: event.availableBiometricMethods,
              userFacingMessage: widget.userFacingBiometricAuthenticationMessage,
            ),
          );
          if (!_isShowingSplashScreen) {
            Overlay.of(context)?.insert(overlayEntry!);
          }
        }
      }
    });
    Future.delayed(widget.splashScreenDuration).then((_) {
      setState(() {
        _isShowingSplashScreen = false;
        if (overlayEntry != null) {
          Overlay.of(context)?.insert(overlayEntry!);
        }
      });
    });
  }

  @override
  void dispose() {
    lockSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LockState>(
      stream: widget.authenticator.lockState,
      builder: (context, snapshot) {
        if (snapshot.hasData && !_isShowingSplashScreen) {
          return widget.child;
        }
        return widget.splashScreenBuilder?.call() ?? const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _LockScreen extends StatelessWidget {
  final Authenticator authenticator;
  final LockScreenBuilder builder;
  final PinInputBuilder inputNodeBuilder;
  final List<BiometricMethod> availableMethods;
  final String userFacingMessage;

  const _LockScreen({
    Key? key,
    required this.authenticator,
    required this.builder,
    required this.availableMethods,
    required this.userFacingMessage,
    required this.inputNodeBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocProvider<LockCubit>(
        create: (context) => LockCubit(authenticator),
        child: BlocBuilder<LockCubit, LockScreenState>(
          builder: (context, state) => builder(
            LockScreenConfiguration(
              pinInputWidget: PinInputWidget(
                value: state.pin,
                pinLength: authenticator.pinLength,
                onInput: (pin) {
                  BlocProvider.of<LockCubit>(context).enterPin(pin);
                },
                inputNodeBuilder: inputNodeBuilder,
                hasError: state.error != null,
              ),
              isLoading: state.isLoading,
              error: state.error,
              availableBiometricMethods: availableMethods,
              onBiometricAuthenticationRequested: () {
                BlocProvider.of<LockCubit>(context).unlockWithBiometrics(userFacingMessage);
              },
            ),
          ),
        ),
      ),
    );
  }
}

typedef SplashScreenBuilder = Widget Function();

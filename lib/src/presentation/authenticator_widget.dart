import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:pin_lock/src/blocs/cubit/lock_cubit.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/lock_state.dart';
import 'package:pin_lock/src/presentation/builders.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

class AuthenticatorWidget extends StatefulWidget {
  final Authenticator authenticator;
  final Widget child;
  final LockScreenBuilder lockScreenBuilder;
  final SplashScreenBuilder? splashScreenBuilder;
  final PinInputBuilder inputNodeBuilder;
  final String userFacingBiometricAuthenticationMessage;

  const AuthenticatorWidget({
    Key? key,
    required this.authenticator,
    required this.child,
    required this.lockScreenBuilder,
    required this.userFacingBiometricAuthenticationMessage,
    required this.inputNodeBuilder,
    this.splashScreenBuilder,
  }) : super(key: key);

  @override
  _AuthenticatorWidgetState createState() => _AuthenticatorWidgetState();
}

class _AuthenticatorWidgetState extends State<AuthenticatorWidget> {
  late final StreamSubscription lockSubscription;
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    lockSubscription = widget.authenticator.lockState.listen((event) {
      event.when(
        unlocked: () {
          overlayEntry?.remove();
          overlayEntry = null;
        },
        locked: (avilableBiometricMethods) {
          if (overlayEntry == null) {
            overlayEntry = OverlayEntry(
              opaque: true,
              builder: (context) => _LockScreen(
                authenticator: widget.authenticator,
                builder: widget.lockScreenBuilder,
                inputNodeBuilder: widget.inputNodeBuilder,
                availableMethods: avilableBiometricMethods,
                userFacingMessage: widget.userFacingBiometricAuthenticationMessage,
              ),
            );
            Overlay.of(context)?.insert(overlayEntry!);
          }
        },
      );
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
        if (snapshot.hasData) {
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

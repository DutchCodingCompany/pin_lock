import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/blocs/cubit/lock_cubit.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/lock_state.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

class AuthenticatorWidget extends StatefulWidget {
  final Authenticator authenticator;
  final Widget child;
  final LockScreenBuilder lockScreenBuilder;
  final PinInputBuilder? inputNodeBuilder;

  const AuthenticatorWidget({
    Key? key,
    required this.authenticator,
    required this.child,
    required this.lockScreenBuilder,
    this.inputNodeBuilder,
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
        locked: (biometricAvailable) {
          if (overlayEntry == null) {
            overlayEntry = OverlayEntry(
              opaque: true,
              builder: (context) => _LockScreen(
                authenticator: widget.authenticator,
                builder: widget.lockScreenBuilder,
                inputNodeBuilder: widget.inputNodeBuilder,
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
        // TODO: Should be a little splash screen instead
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

typedef LockScreenBuilder = Widget Function(
  Widget pinInputWidget,
  bool isLoading,
  LocalAuthFailure? error,
);

class _LockScreen extends StatelessWidget {
  final Authenticator authenticator;
  final LockScreenBuilder builder;
  final PinInputBuilder? inputNodeBuilder;

  const _LockScreen({
    Key? key,
    required this.authenticator,
    required this.builder,
    this.inputNodeBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocProvider<LockCubit>(
        create: (context) => LockCubit(authenticator),
        child: BlocBuilder<LockCubit, LockScreenState>(
          builder: (context, state) => builder(
            PinInputWidget(
              value: state.pin,
              pinLength: authenticator.pinLength,
              onInput: (pin) {
                BlocProvider.of<LockCubit>(context).enterPin(pin);
              },
              inputNodeBuilder: inputNodeBuilder,
            ),
            state.isLoading,
            state.error,
          ),
        ),
      ),
    );
  }
}

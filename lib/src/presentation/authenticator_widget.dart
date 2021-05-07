import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/blocs/cubit/lock_cubit.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/lock_state.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

class AuthenticatorWidget extends StatefulWidget {
  final Authenticator authenticator;
  final Widget child;

  const AuthenticatorWidget({
    Key? key,
    required this.authenticator,
    required this.child,
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
              builder: (context) => LockScreen(
                authenticator: widget.authenticator,
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

class LockScreen extends StatefulWidget {
  final Authenticator authenticator;

  const LockScreen({Key? key, required this.authenticator}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: BlocProvider<LockCubit>(
        create: (context) => LockCubit(widget.authenticator),
        child: BlocBuilder<LockCubit, LockScreenState>(
          builder: (context, state) => SafeArea(
            child: Column(
              children: [
                const Text('the app is locked'),
                const Text('enter pin'),
                PinInputWidget(
                  value: state.pin,
                  pinLength: widget.authenticator.pinLength,
                  onInput: (pin) {
                    BlocProvider.of<LockCubit>(context).enterPin(pin);
                  },
                ),
                if (state.error != null)
                  Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

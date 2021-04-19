import 'package:flutter/material.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/lock_state.dart';

class AuthenticatorWidget extends StatelessWidget {
  final Authenticator authenticator;
  final Widget child;

  const AuthenticatorWidget({
    Key? key,
    required this.authenticator,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LockState>(
      stream: authenticator.lockController.state,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;
          if (data != null) {
            return data.when(
              unlocked: () => child,
              locked: (_) => const Center(child: Text('Locked')),
            );
          }
          return child;
        }
        // TODO: Should be a little splash screen instead
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

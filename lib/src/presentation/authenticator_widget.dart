import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:pin_lock/src/blocs/cubit/lock_cubit.dart';

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
  /// position ([index]) and its [InputFieldState]
  final PinInputBuilder inputNodeBuilder;

  /// If true, hides the app thumbnail from App Switcher. On iOS it displays either the asset
  /// passed as [iosImageAsset] or a black or white screen (depending on whether the phone is in dark or
  /// light mode) if [iosImageAsset] is `null`.
  /// On Android `LayoutParams.FLAG_SECURE` is used, resulting in a black screen instead of thumbnail.
  final bool hideAppContent;

  /// iOS only! Asset to display when the app is in App Switcher and [hideAppContent] is `true`. If `null`, a black or
  /// white screen will be displayed instead (depending on whether the phone is in dark or light mode).
  /// Ignored on Android.
  final String? iosImageAsset;

  const AuthenticatorWidget({
    Key? key,
    required this.authenticator,
    required this.child,
    required this.lockScreenBuilder,
    required this.userFacingBiometricAuthenticationMessage,
    required this.inputNodeBuilder,
    this.splashScreenBuilder,
    this.splashScreenDuration = Duration.zero,
    this.hideAppContent = true,
    this.iosImageAsset,
  }) : super(key: key);

  @override
  State<AuthenticatorWidget> createState() => _AuthenticatorWidgetState();
}

class _AuthenticatorWidgetState extends State<AuthenticatorWidget> {
  late final StreamSubscription lockSubscription;
  OverlayEntry? overlayEntry;
  bool _isShowingSplashScreen = true;
  late final Stream<PinLockState> lockState;

  @override
  void initState() {
    super.initState();
    lockState = widget.authenticator.lockState;
    PinLock.setHideAppContent(
      preference: widget.hideAppContent,
      iosAssetImage: widget.iosImageAsset,
    );
    lockSubscription = lockState.listen((event) {
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
            // As of flutter 3.7.0 these will be non-null. For they are kept in place.
            Overlay.of(context)?.insert(overlayEntry!);
          }
        }
      }
    });
    Future.delayed(widget.splashScreenDuration).then((_) {
      setState(() {
        _isShowingSplashScreen = false;
        if (overlayEntry != null) {
          // As of flutter 3.7.0 these will be non-null. For they are kept in place.
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
    return StreamBuilder<PinLockState>(
      stream: lockState,
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_lock/pin_lock.dart';

// The app should contain only one instance of [Authenticator], otherwise
// the locking behaviour can become unpredictable
late final Authenticator globalAuthenticator;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// The easiest way to initialize [Authenticator] is to use [baseAuthenticator]
  /// It creates an instance with all the default parts, given the [userId]
  /// If you want to override any of the defaults (e.g., provide a different local
  /// storage library or have custom callbacks when the app is locked/unlocked), use
  /// [PinLock.authenticatorInstance()]
  globalAuthenticator = await PinLock.baseAuthenticator('1');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    /// [Authenticator] needs to be registered as an app lifecycle observer
    WidgetsBinding.instance.addObserver(globalAuthenticator);
  }

  @override
  void dispose() {
    /// When disposing of the app, remove [Authenticator]'s subscription
    /// to lifecycle events
    WidgetsBinding.instance.removeObserver(globalAuthenticator);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.indigo),
        ),
      ),

      /// Use the [AuthenticatorWidget] as the root widget of the part of the application that
      /// needs to be protected by a pin lock
      home: AuthenticatorWidget(
        /// Pass a reference to your [Authenticator] singleton
        authenticator: globalAuthenticator,

        /// Provide a string that users will see when biometric authentication is triggered
        userFacingBiometricAuthenticationMessage:
            'Your data is locked for privacy reasons. You need to unlock the app to access your data.',

        /// Provide a widget that represents a single pin input field
        inputNodeBuilder: (index, state) =>
            _InputField(state: state, index: index),

        /// Provide a widget that describes what you want your lock screen to look like,
        /// given the state of the lock screen ([LockScreenConfiguration])
        lockScreenBuilder: (configuration) => _LockScreen(configuration),

        /// Optional image to use to prevent from showing app content in the App Switcher.
        iosImageAsset: 'AppIcon',

        /// [child] should be the widget that you'd normally pass in as [home] of your [MaterialApp]
        child: _Home(),
      ),
    );
  }
}

/// Represents a visual representation of a single digit of the pin code
/// [InputFieldState] tells the UI wchich state it should draw
/// Optionally, you can modify what the input widgets look like based on their position,
/// e.g., if you want a prefix or a suffix in your pin widget, you'd add it to
/// the `0-th` or `(n-1)-th` input field
class _InputField extends StatelessWidget {
  final InputFieldState state;
  final int index;
  const _InputField({
    Key? key,
    required this.state,
    required this.index,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final borderColor = state == InputFieldState.error
        ? Theme.of(context).errorColor
        : Theme.of(context).primaryColor;
    double borderWidth = 1;
    if (state == InputFieldState.focused ||
        state == InputFieldState.filledAndFocused) {
      borderWidth = 4;
    }
    return Container(
      height: 40,
      width: 46,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: state == InputFieldState.filled ||
              state == InputFieldState.filledAndFocused
          ? Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo,
                ),
              ),
            )
          : Container(),
    );
  }
}

class _Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PinLock example app'),
      ),
      body: Column(
        children: [
          Text(
            'This is the home screen',
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => _SetupAuthWidget()));
            },
            child: Text('Configure local authentication'),
          ),
        ],
      ),
    );
  }
}

/// Specify what your lock screen should look like based on
/// current state. See [LockScreenConfiguration] documentation for a list of all
/// available information
class _LockScreen extends StatelessWidget {
  final LockScreenConfiguration configuration;

  const _LockScreen(this.configuration, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Fill in your pincode to unlock the app'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// [LockScreenConfiguration] provides [pinInputWidget] drawn based on
              /// your instructions given to [AuthenticatorWidget]. You need to make sure that it is
              /// visible on your lock screen, while PinLock package takes care of its state
              configuration.pinInputWidget,

              /// You can check whether biometric authentication is available, and
              /// adjust your UI accordingly
              if (configuration.availableBiometricMethods.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.fingerprint),
                  onPressed: configuration.onBiometricAuthenticationRequested,
                ),
            ],
          ),

          /// [LockScreenConfiguration] provides the [error] property, based on which you can display
          /// an error message to your user based on the specific [LocalAuthFailure]
          if (configuration.error != null)
            Text(
              configuration.error.toString(),
              style: const TextStyle(color: Colors.red),
            )
        ],
      ),
    );
  }
}

/// [AuthenticationSetupWidget] provides several builder properties with appropriate configuration.
/// If you do not want your app to support some of the features (e.g., changing pincode), simply
/// return a `Container` from its builder
class _SetupAuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),

      /// Put [AuthenticationSetupWidget] in your settings screen, or wherever you want
      /// your user expects to be able to change pin preferences
      body: AuthenticationSetupWidget(
        /// Pass in a reference to an [Authenticator] singleton
        authenticator: globalAuthenticator,

        /// Pin input widget can be the same as on the lock screen, or you can provide a custom UI
        /// that you want to use when setting it up
        pinInputBuilder: (index, state) =>
            _InputField(state: state, index: index),

        /// Overview refers to the first thing your user sees when getting to settings, before they have made
        /// any action, as well as after they made an action (such as changing pincode)
        /// See [OverviewConfiguration] for all the data available to you
        overviewBuilder: (config) => Center(
          /// [isLoading] indicates that user's preferences are still being fetched
          child: config.isLoading
              ? CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// [isPinEnabled] is only `null` while [isLoading] is `true`
                          Text('Secure the app with a pin code'),
                          Switch(
                            value: config.isPinEnabled!,

                            /// [onTogglePin] callback is passed to a button (or a switch) that user
                            /// clicks to change their preferences
                            onChanged: (_) => config.onTogglePin(),
                          ),
                        ],
                      ),

                      /// In case of something going wrong, [OverviewConfiguration] provides an [error] property
                      if (config.error != null)
                        Text(config.error!.toString(),
                            style: TextStyle(color: Colors.red)),

                      /// If biometric authentication is available, provide an option to toggle it on or off
                      if (config.isBiometricAuthAvailable == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                                'Use fingerprint or face id to unlock the app'),
                            Switch(
                              value: config.isBiometricAuthEnabled!,
                              onChanged: (_) => config.onToggleBiometric(),
                            ),
                          ],
                        ),

                      /// If pin is enabled, you can give your user an option to change it
                      if (config.isPinEnabled == true)
                        OutlinedButton(
                          /// If you do not the pincode to be changable, simply never trigger [config.onPasswordChangeRequested]
                          /// If this callback is never triggered, the [changingWidget] builder is never needed, so it is
                          /// save to have it simply return a `Container` or a `SizedBox`
                          onPressed: config.onPasswordChangeRequested,
                          child: const Text('Change passcode'),
                        ),
                    ],
                  ),
                ),
        ),

        /// EnablingWidget is a builder that describes what [AuthenticationSetupWidget] looks like while pin code is being enabled
        /// See [EnablingPinConfiguration] for more detail
        enablingWidget: (configuration) => Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('Select a pin code that you can remember'),

              /// Make sure [configuration.pinInputWidget] and [configuration.pinConfirmationWidget] are visible on the screen, since
              /// they are the main point of interaction between your user and the PinLock package
              configuration.pinInputWidget,
              const SizedBox(height: 24),
              const Text('Repeat the same pin once more'),

              /// [pinInputWidget] and [pinConfirmationWidget] can be presented side by side or one by one
              configuration.pinConfirmationWidget,

              /// [configuration.error] provides details if something goes wrong (e.g., pins don't match)
              if (configuration.error != null)
                Text(configuration.error.toString(),
                    style: TextStyle(color: Colors.red)),

              /// [configuration.canSubmitChange] can optionaly be used to hide or disable submit button
              /// It is also possible to listen for this property and programatically trigger [config.onSubmitChange],
              /// for example if you want to make a call to the library as soon as the fields are filled, without
              /// making the user press a button
              if (configuration.canSubmitChange)
                OutlinedButton(
                  onPressed: configuration.onSubmitChange,
                  child: const Text('Save'),
                )
            ],
          ),
        ),

        /// DisablingWidget is a builder that describes what [AuthenticationSetupWidget] looks like while pin code is being disabled
        /// See [DisablingPinConfiguration] for more detail
        disablingWidget: (configuration) => Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text('Enter your pin to disable pin authentication'),

              /// Make sure [configuration.pinInputWidget] is visible on the screen
              configuration.pinInputWidget,

              /// Display errors if there is any
              if (configuration.error != null)
                Text(
                  configuration.error.toString(),
                  style: TextStyle(color: Colors.red),
                ),
              if (configuration.canSubmitChange)
                OutlinedButton(
                    onPressed: configuration.onChangeSubmitted,
                    child: Text('Save'))
            ],
          ),
        ),

        changingWidget: (configuration) => Column(
          children: [
            const Text('Enter current pin'),
            configuration.oldPinInputWidget,
            if (_isCurrentPinIssue(configuration.error))
              Text(
                configuration.error!.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            const Text('Enter new pin'),
            configuration.newPinInputWidget,
            const Text('Confirm new pin'),
            configuration.confirmNewPinInputWidget,
            if (configuration.error != null &&
                !_isCurrentPinIssue(configuration.error))
              Text(
                configuration.error!.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            if (configuration.canSubmitChange)
              TextButton(
                onPressed: configuration.onSubimtChange,
                child: const Text('Save'),
              )
          ],
        ),
      ),
    );
  }

  bool _isCurrentPinIssue(LocalAuthFailure? error) {
    return error == LocalAuthFailure.wrongPin ||
        error == LocalAuthFailure.tooManyAttempts;
  }
}

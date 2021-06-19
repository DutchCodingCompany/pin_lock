import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Authenticator globalAuthenticator;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPref = await SharedPreferences.getInstance();
  globalAuthenticator = PinLock.authenticatorInstance(
    repository: LocalAuthenticationRepositoryImpl(sharedPref),
    biometricAuthenticator: LocalAuthentication(),
    lockController: LockController(),
    userId: UserId('1'),
  );
  runApp(MyApp(sp: sharedPref));
}

class MyApp extends StatefulWidget {
  final SharedPreferences sp;

  const MyApp({Key? key, required this.sp}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(globalAuthenticator);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(globalAuthenticator);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText2: TextStyle(color: color),
        ),
      ),
      home: Builder(
        builder: (navContext) => AuthenticatorWidget(
          authenticator: globalAuthenticator,
          userFacingBiometricAuthenticationMessage:
              'Your data is locked for privacy reasons. Please authenticate to access it.',
          inputNodeBuilder: (index, state) => InputField(state: state),
          lockScreenBuilder: (configuration) => SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Fill in your pincode'),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(child: configuration.pinInputWidget),
                      IconButton(
                        icon: Icon(Icons.fingerprint),
                        onPressed: configuration.onBiometricAuthenticationRequested,
                      )
                    ],
                  ),
                ),
                if (configuration.error != null)
                  Text(
                    configuration.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  )
              ],
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Center(
              child: Column(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(navContext).push(SetupAuthWidget.route());
                      },
                      child: Text('setup auth')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const Color color = Color(0xFF474854);

class InputField extends StatelessWidget {
  final InputFieldState state;
  const InputField({
    Key? key,
    required this.state,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 46,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: state == InputFieldState.focused ? 4 : 1),
      ),
      child: state == InputFieldState.filled
          ? Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            )
          : Container(),
    );
  }
}

class SetupAuthWidget extends StatelessWidget {
  static MaterialPageRoute route() => MaterialPageRoute(builder: (_) => SetupAuthWidget());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AuthenticationSetupWidget(
        authenticator: globalAuthenticator,
        pinInputBuilder: (index, state) => InputField(state: state),
        overviewBuilder: (config) => Center(
          child: config.isLoading
              ? CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (config.isPinEnabled != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pin authentication is ${config.isPinEnabled! ? 'enabled' : 'disabled'}'),
                            TextButton(
                              onPressed: config.onTogglePin,
                              child: Text(config.isPinEnabled! ? 'Disable' : 'Enable'),
                            ),
                          ],
                        ),
                      if (config.error != null) Text(config.error!.toString()),
                      if (config.isPinEnabled == true && config.isBiometricAuthAvailable == true) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Unlock with biometrics'),
                            TextButton(
                              onPressed: config.onToggleBiometric,
                              child: Text(config.isBiometricAuthEnabled == true ? 'Disable' : 'Enable'),
                            ),
                          ],
                        )
                      ],
                      if (config.isPinEnabled == true && config.isBiometricAuthAvailable != null)
                        TextButton(
                          onPressed: config.onPasswordChangeRequested,
                          child: const Text('change passcode'),
                        ),
                    ],
                  ),
                ),
        ),
        enablingWidget: (configuration) => Center(
          child: Column(
            children: [
              configuration.pinInputWidget,
              configuration.pinConfirmationWidget,
              if (configuration.error != null) Text(configuration.error.toString()),
              if (configuration.canSubmitChange)
                TextButton(
                  onPressed: configuration.onSubmitChange,
                  child: const Text('Save'),
                )
            ],
          ),
        ),
        disablingWidget: (configuration) => Center(
          child: Column(
            children: [
              Text('Enter your pin to disable pin authentication'),
              configuration.pinInputWidget,
              if (configuration.error != null) Text(configuration.error.toString()),
              if (configuration.canSubmitChange)
                TextButton(onPressed: configuration.onChangeSubmitted, child: Text('Save'))
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
            const Text('confirm new pin'),
            configuration.confirmNewPinInputWidget,
            if (configuration.error != null && !_isCurrentPinIssue(configuration.error))
              Text(
                configuration.error!.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            if (configuration.canSubmitChange)
              TextButton(
                onPressed: configuration.onSubimtChange,
                child: const Text('save'),
              )
          ],
        ),
      ),
    );
  }

  bool _isCurrentPinIssue(LocalAuthFailure? error) {
    return error == LocalAuthFailure.wrongPin || error == LocalAuthFailure.tooManyAttempts;
  }
}

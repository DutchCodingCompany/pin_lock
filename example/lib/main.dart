import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Authenticator globalAuthenticator;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPref = await SharedPreferences.getInstance();
  globalAuthenticator = AuthenticatorImpl(
    LocalAuthenticationRepositoryImpl(sharedPref),
    LocalAuthentication(),
    LockController(),
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
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance?.addObserver(globalAuthenticator);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(globalAuthenticator);
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PinLock.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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
          inputNodeBuilder: (index, state) => InputField(state: state),
          lockScreenBuilder: (pinInputWidget, isLoading, error) => SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Fill in your pincode'),
                pinInputWidget,
                if (error != null)
                  Text(
                    error.toString(),
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
                  Text('Running on: $_platformVersion\n'),
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
      ),
    );
  }
}

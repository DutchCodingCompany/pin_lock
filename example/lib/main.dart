import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/lock_controller.dart';
import 'package:pin_lock/src/entities/value_objects.dart';
import 'package:pin_lock/src/presentation/authenticator_widget.dart';
import 'package:pin_lock/src/presentation/authentication_setup_widget.dart';
import 'package:pin_lock/src/repositories/pin_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

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
          inputNodeBuilder: (index, state, text) => InputField(state: state),
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
      ),
    );
  }
}

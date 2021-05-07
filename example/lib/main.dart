import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/lock_controller.dart';
import 'package:pin_lock/src/entities/value_objects.dart';
import 'package:pin_lock/src/presentation/authenticator_widget.dart';
import 'package:pin_lock/src/presentation/setup_authentication_widget.dart';
import 'package:pin_lock/src/repositories/pin_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Authenticator globalAuthenticator;
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

  const MyApp({Key key, @required this.sp}) : super(key: key);
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
      home: Builder(
        builder: (navContext) => AuthenticatorWidget(
          authenticator: globalAuthenticator,
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

class SetupAuthWidget extends StatelessWidget {
  static MaterialPageRoute route() => MaterialPageRoute(builder: (_) => SetupAuthWidget());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SetupAuthenticationWidget(
        authenticator: globalAuthenticator,
      ),
    );
  }
}

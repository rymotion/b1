import 'package:local_auth/local_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/services.dart';

LocalAuthentication _authentication = new LocalAuthentication();
List<BiometricType> availableBiometrics;
bool isAuth = false;
bool signIn = false;

class AuthentificationView extends StatefulWidget {
  @override _AuthState createState() => _AuthState();
}

class _AuthState extends State<AuthentificationView> {
  @override Widget build(BuildContext context) {
    return new CupertinoPageScaffold(child: new SafeArea(
      child: Container( padding: EdgeInsets.all(15.0),
        child: new Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          Text("No need to sign up just press Sign In"),
          new CupertinoButton(
              child: new Text("Login"),
              onPressed: () {authUser(context);}),
          new CupertinoButton(
              child: new Text("Terms of Service")),
      ]))
    ));
  }

  Widget authUser(BuildContext context) {
    getPlatformAuth();
    checkPlatformAuth();
    authenticate();
    if (signIn){
      Navigator.pop(context);
    }
  }

  Future<void> getPlatformAuth() async {
    List<BiometricType> _availableBiometrics;
    try {
      _availableBiometrics = await _authentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print("${e.message}");
    }
    setState(() {
      availableBiometrics = _availableBiometrics;
    });
  }

  Future<void> checkPlatformAuth() async {
    bool canAuth;
    try {
      canAuth = await _authentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print("${e.message}");
    }
    setState(() {
      isAuth = canAuth;
    });
  }

  Future<void> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await _authentication.authenticateWithBiometrics(
          localizedReason: "Let's get you logged in.",
          useErrorDialogs: true,
          stickyAuth: true);
    } on PlatformException catch (e) {
      print("${e.message}");
    }
    setState(() {
      signIn = authenticated ? true : false;
      if (signIn){print("youre in");}

    });
  }
}

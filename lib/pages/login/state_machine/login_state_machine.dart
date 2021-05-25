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

const authChannel = const MethodChannel('com.b1.blockchain/register');

class _AuthState extends State<AuthentificationView> {
  @override Widget build(BuildContext context) {
    return new CupertinoPageScaffold(child: new SafeArea(
      child: Container( padding: EdgeInsets.all(15.0),
        child: new Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          Text("No need to sign up just press Sign In"),
          new CupertinoButton(
              child: new Text("Sign In"),
              onPressed: () {
                getPlatformAuth();
                checkPlatformAuth();
                Stream<bool> hasAuth = new Stream.fromFuture(authenticate());
                hasAuth.listen( (onData){
                  print("listened Data: $onData");
                  return Navigator.pop(context);
                  }, onDone: (){ print("Signed In status: $signIn");
                  Navigator.pop(context);
                  }, 
                  onError: (error){
                    print("Fired error");
                  }
    );
          }),
          new CupertinoButton(
              child: new Text("Terms of Service"), onPressed: (){},),
      ]))
    ));
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

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await _authentication.authenticateWithBiometrics(
          localizedReason: "Let's get you logged in.",
          useErrorDialogs: true,
          stickyAuth: true);
      final Map<String, bool> status = await authChannel.invokeMapMethod('register', <String, dynamic>{"authUser" : true});
      print("key status: ${status.keys} | ${status.values.first}");
      setState(() {
        signIn = status.values.first;
      });
      return signIn;
    } on PlatformException catch (e) {
      print("${e.message}");
    }
    // setState(() {
    //   signIn = authenticated ? true : false;
    // });
    return signIn;
  }
}

/// TODO(rpaglinawan) create entrypoint for login workflow
/**
 * entrypoint(biometric sign in/ sign up)
 * sign-up path -> sign-up successful state / sign-up unsuccessful state
 * sign-in successful state
 * sign-in unsuccessful state
 */

class LoginRoutes {
  static const entrypoint = 'login-entrypoint';

  static const signUp = 'sign-up-entrypoint';

  static const signUp_success = 'sign-up-success';

  static const signUp_fail = 'sign-up-fail';

  static const signIn = 'sign-in-entrypoint';

  static const signIn_success = 'sign-in-success';

  static const signIn_fail = 'sign-in-fail';
}

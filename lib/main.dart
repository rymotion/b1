import 'package:flutter/cupertino.dart';
import 'package:blockchain/pages/login/view/login.dart';
import 'package:blockchain/pages/create_listing/view/create_listing.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const channel = BasicMessageChannel("checkAuth", StandardMessageCodec());

class _MyHomePageState extends State<MyHomePage> {
  Future<bool> loggedIn() async {
    final bool reply = await channel.send("wasAuth");
    channel.setMessageHandler((handler) async {
      print(handler as bool);
    });
    return reply;
  }

  @override
  void initState() {
    super.initState();
    Stream<bool> hasAuth = new Stream.fromFuture(loggedIn());
    hasAuth.listen((onData) {
      switch (onData) {
        case true:
          return;
          break;
        default:
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: new Text("You're new"),
                  content: new Text("Let's get you signed up and logged in."),
                  actions: <Widget>[
                    CupertinoButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              new CupertinoPageRoute(
                                  builder: (_) => AuthentificationView()));
                        },
                        child: new Text("Login"))
                  ],
                );
              });
          break;
      }
    }, onDone: () {
      print("Done");
    }, onError: (error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    // check if you logged in before
    return CupertinoPageScaffold(
      child: SafeArea(
          child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          /// contains type of [UIMapView]
          Container(
            decoration:
                BoxDecoration(borderRadius: new BorderRadius.circular(20.0)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: UiKitView(viewType: 'UIMapView'),
            ),
          ),
          /// contains row of options
          Container(
            color: Colors.white,
            child: Placeholder(
              color: Colors.white,
            ),
          ),
        ],
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

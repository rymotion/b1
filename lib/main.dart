import 'package:flutter/cupertino.dart';
import 'package:blockchain/pages/login.dart' as auth;
import 'package:blockchain/pages/createListing.dart' as camera;
import 'dart:async';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override Widget build(BuildContext context) {
    return CupertinoApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override _MyHomePageState createState() => _MyHomePageState();
}

const channel = BasicMessageChannel("checkAuth", StandardMessageCodec());

class _MyHomePageState extends State<MyHomePage> {
  Future<bool> loggedIn() async {
    final bool reply = await channel.send("wasAuth");
    return reply;
  }

  @override void initState() {
    super.initState();
    Stream<bool> hasAuth = new Stream.fromFuture(loggedIn());
    hasAuth.listen( (onData) {
          switch (onData) {
            case true:
              print(true);
              break;
            default:
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: new Text("You're new"),
                      content: new Text("Let's get you signed up and logged in."),
                      actions: <Widget>[
                        CupertinoButton( onPressed: () {
                              Navigator.push(context, new CupertinoPageRoute(builder: (_) => auth.AuthentificationView()));
                        },
                        child: new Text("Login"))
                      ],
                    );
                  });
              break;
          }
        },
        onDone: () {
          print("Done");
        },
        onError: (error) {
          print(error);
        });
  }

  @override Widget build(BuildContext context) {
    // check if you logged in before
    return CupertinoPageScaffold(
      child: SafeArea(
          child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration:
                BoxDecoration(borderRadius: new BorderRadius.circular(20.0)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: UiKitView(viewType: 'UIMapView'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Color.fromRGBO(0, 0, 0, 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupertinoButton(
                  child: new Container(
                    padding: const EdgeInsets.all(15.0),
                    color: Color(0xFFFFFFFF),
                    width: 60.0,
                    height: 50.0,
                    child: new Text("Sell"),
                  ),
                  onPressed: () {
                    Navigator.push( context,
                        new CupertinoPageRoute(builder: (_) => camera.CreateListingView()));
                  },
                ),
                CupertinoButton(
                  child: new Container(
                    padding: const EdgeInsets.all(15.0),
                    color: Color(0xFFFFFFFF),
                    width: 60.0,
                    height: 50.0,
                    child: new Text("Buy"),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  /**
   * CupertinoButton(
            onPressed: () => Navigator.push(
                context,
                new CupertinoPageRoute(
                    builder: (_) => auth.AuthentificationView())),
            child: new Text("Login"),
          )
   */
}

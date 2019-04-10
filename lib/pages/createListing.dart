import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CreateListingView extends StatefulWidget {
  @override _CreateListingState createState() => _CreateListingState();
}

class _CreateListingState extends State<CreateListingView> {
  static const camera = const MethodChannel('com.b1.blockchain/camera');
  Future<void> _takePicture() async{
    // invoke method channel
    try {
      final dynamic result = await camera.invokeMethod('takePic');
      print("what is this? ${result.runtimeType}\n");
    } on PlatformException catch(e){

    }
  }

  @override Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
      child: SafeArea(
        child: new Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Container( padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(borderRadius: new BorderRadius.circular(20.0)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: UiKitView(viewType: 'UICameraView'),
              )),
            CupertinoButton(
              child: Container(
                color: Color(0xFFFFFFFF),
                child: Icon(CupertinoIcons.photo_camera_solid),
              ),
              onPressed: () async {_takePicture();},
            ),
          ],
        ),
      ),
    );
  }
}
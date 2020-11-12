import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class CreateListingView extends StatefulWidget {
  @override _CreateListingState createState() => _CreateListingState();
}

class _CreateListingState extends State<CreateListingView> {
  static const camera = const MethodChannel('com.b1.blockchain/camera');
  List<Uint8List> _imageCarousel = new List<Uint8List>();

  Future<void> _takePicture() async {
    // invoke method channel
    try {
      final Uint8List result = await camera.invokeMethod('takePic');
      setState(() {
        _imageCarousel.add(result);
      });
    } on PlatformException catch (e) {
      print("${e.details}");
    }
  }

  Widget cameraView({BuildContext context}){
    return new Stack( alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        // load in images from camera stream
        Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(50.0)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: UiKitView(viewType: 'UICameraView'),
            )),
        CupertinoButton(
          child: Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            color: Color(0xFFFFFFFF),
            child: Icon(CupertinoIcons.photo_camera_solid, size: 50.0,),
          ),
          onPressed: () async {
            _takePicture();
          },
        ),
      ],
    );
  }

  Widget imageCarousel({BuildContext context}){
    return new StreamBuilder <Uint8List>(
      stream: Stream.fromIterable(_imageCarousel),
      // initialData: _imageCarousel.first,
      builder: (context, AsyncSnapshot<Uint8List> _images){
        if (_images.hasData) {
          return new Container(
            height: 100.0,
            width: MediaQuery.of(context).size.width,
            color: Color(0xFFFFFFFF),
            padding: const EdgeInsets.all(5.0),
            child: Image.memory(_images.data),
          );
        } else {
          return Container(
            height: 100.0,
            width: MediaQuery.of(context).size.width,
            color: Color(0xFFFFFFFF),
            padding: const EdgeInsets.all(5.0),
            child: Text("Start taking images for potential buyers"),
          );
        }
      },
    );
  }
  @override Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
      child: SafeArea( child: new Stack( alignment:  AlignmentDirectional.topCenter,
        children: <Widget>[
          // CameraView
          cameraView(context: context),
          // returned image result
          imageCarousel(context: context)
        ],
      )),
    );
  }
}

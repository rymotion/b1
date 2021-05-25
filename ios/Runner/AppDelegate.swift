import UIKit
import Flutter
import Firebase

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? ) -> Bool {
    
    let mapViewFactory = MapViewFactory()
    let cameraViewFactory = CameraViewFactory()
    
	FirebaseApp.configure()
	
	guard let controller: FlutterViewController = window?.rootViewController as? FlutterViewController, let mapRunner: FlutterPluginRegistrar = registrar(forPlugin: "Runner"), let cameraRunner: FlutterPluginRegistrar =  registrar(forPlugin: "camera") else {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
	mapRunner.register(mapViewFactory, withId: "UIMapView")
	cameraRunner.register(cameraViewFactory, withId: "UICameraView")
    
    let userdefaults = UserDefaults.standard.bool(forKey: "authUser")
    
	let authChannel = FlutterBasicMessageChannel(name: "checkAuth", binaryMessenger: controller as! FlutterBinaryMessenger, codec: FlutterStandardMessageCodec.sharedInstance())
    
	let registerChannel = FlutterMethodChannel(name: "com.b1.blockchain/register", binaryMessenger: controller as! FlutterBinaryMessenger)
    
	let cameraChannel = FlutterMethodChannel(name: "com.b1.blockchain/camera", binaryMessenger: controller as! FlutterBinaryMessenger)
    
    cameraChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult) -> Void in
        switch(call.method){
        case "takePic":
            cameraViewFactory._uiCameraHandle._customCamera.takePicture {
                (data, error) in
                print(data ?? "No Data")
                print(error ?? "NoError")
            }
            
            result(cameraViewFactory._uiCameraHandle._customCamera.imageData)
            break
        default:
            break
        }
        print(cameraViewFactory._uiCameraHandle._customCamera.imageData.description)
        print(cameraViewFactory._uiCameraHandle._customCamera.imageData.count)
    })
    
    authChannel.sendMessage(userdefaults)
    
    registerChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult) -> Void in
        switch(call.method){
        case "register":
            guard let args = call.arguments as? [String:Any] else { return }
            UserDefaults.standard.set(args["authUser"], forKey: "authUser")
            UserDefaults.standard.synchronize()
            UserDefaults.standard.set(NSUUID().uuidString, forKey: "uid")
            UserDefaults.standard.synchronize()
            break
        default:
            print("You got here")
            break
        }
        
        if UserDefaults.standard.bool(forKey: "authUser"), UserDefaults.standard.object(forKey: "uid") as? String != nil {
            result(["Status":true])
        } else {
            result(["Status":false])
        }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

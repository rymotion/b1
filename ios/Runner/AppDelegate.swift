import UIKit
import Flutter

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? ) -> Bool {
    
    let mapViewFactory = MapViewFactory()
    let cameraViewFactory = CameraViewFactory()
    
    
    guard let controller: FlutterViewController = window?.rootViewController as? FlutterViewController else {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    registrar(forPlugin: "Runner").register(mapViewFactory, withId: "UIMapView")
    registrar(forPlugin: "camera").register(cameraViewFactory, withId: "UICameraView")
    
    let userdefaults = UserDefaults.standard.bool(forKey: "authUser")
    
    let authChannel = FlutterBasicMessageChannel(name: "checkAuth", binaryMessenger: controller, codec: FlutterStandardMessageCodec.sharedInstance())
    
    let registerChannel = FlutterMethodChannel(name: "com.b1.blockchain/register", binaryMessenger: controller)
    
    let cameraChannel = FlutterMethodChannel(name: "com.b1.blockchain/camera", binaryMessenger: controller)
    
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

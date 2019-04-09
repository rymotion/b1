import UIKit
import Flutter

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? ) -> Bool {
    
    let mapViewFactory = MapViewFactory()
    
    guard let controller: FlutterViewController = window?.rootViewController as! FlutterViewController else {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    registrar(forPlugin: "Runner").register(mapViewFactory, withId: "UIMapView")
    let userdefaults = UserDefaults.standard.bool(forKey: "authUser")
    
    let authChannel = FlutterBasicMessageChannel(name: "checkAuth", binaryMessenger: controller, codec: FlutterStandardMessageCodec.sharedInstance())
    
    authChannel.sendMessage(userdefaults){(reply: Any?) -> Void in print("hold.")}
    
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

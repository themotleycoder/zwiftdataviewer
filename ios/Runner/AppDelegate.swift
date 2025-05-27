import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Handle URL schemes for authentication callbacks
    if url.scheme == "zwiftdataviewer" {
      // This will be handled by the Flutter app
      return super.application(app, open: url, options: options)
    }
    return super.application(app, open: url, options: options)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    // Notify Flutter that the app became active
    // This helps with refreshing data after returning from external auth
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app_lifecycle", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("didBecomeActive", arguments: nil)
    }
  }
  
  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)
    // Notify Flutter that the app will resign active
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app_lifecycle", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("willResignActive", arguments: nil)
    }
  }
}

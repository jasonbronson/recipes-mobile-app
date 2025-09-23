import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let sharedChannelName = "com.bronson.dev.iosapp/shared_data"
  private let appGroupID = "group.com.bronson.dev.iosapp"
  private let sharedContentKey = "sharedContent"
  private var sharedDataChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let registrar = self.registrar(forPlugin: "SharedDataChannelPlugin") {
      let channel = FlutterMethodChannel(name: sharedChannelName,
                                         binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { _, result in
        result(FlutterMethodNotImplemented)
      }
      sharedDataChannel = channel
    }

    DispatchQueue.main.async { [weak self] in
      _ = self?.deliverSharedContentIfAvailable()
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    DispatchQueue.main.async { [weak self] in
      _ = self?.deliverSharedContentIfAvailable()
    }
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.scheme == "iosapp" {
      if !(deliverSharedContentIfAvailable()) {
        sharedDataChannel?.invokeMethod("sharedData", arguments: url.absoluteString)
      }
      return true
    }

    return super.application(app, open: url, options: options)
  }

  @discardableResult
  private func deliverSharedContentIfAvailable() -> Bool {
    guard let channel = sharedDataChannel,
          let defaults = UserDefaults(suiteName: appGroupID),
          let sharedContent = defaults.string(forKey: sharedContentKey) else {
      return false
    }

    channel.invokeMethod("sharedData", arguments: sharedContent)
    defaults.removeObject(forKey: sharedContentKey)
    defaults.synchronize()
    return true
  }
}

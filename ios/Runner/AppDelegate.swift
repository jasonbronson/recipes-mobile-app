import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let sharedChannelName = "com.bronson.dev.iosapp/shared_data"
  private let appGroupID = "group.com.bronson.dev.iosapp"
  private let sharedContentQueuePrefix = "sharedContentQueue::"
  private let legacySharedContentKey = "sharedContent"
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
          let defaults = UserDefaults(suiteName: appGroupID) else {
      return false
    }

    defaults.synchronize()
    migrateLegacyContentIfNeeded(defaults: defaults)

    let queuedItems = queuedSharedContent(from: defaults)
    if queuedItems.isEmpty {
      return false
    }

    for item in queuedItems {
      defaults.removeObject(forKey: item.key)
      channel.invokeMethod("sharedData", arguments: item.value)
    }

    defaults.synchronize()
    return true
  }

  private func migrateLegacyContentIfNeeded(defaults: UserDefaults) {
    guard let legacy = defaults.string(forKey: legacySharedContentKey),
          !legacy.isEmpty else {
      return
    }

    let key = makeQueueEntryKey(timestamp: Date().timeIntervalSince1970 - 1)
    defaults.set(legacy, forKey: key)
    defaults.removeObject(forKey: legacySharedContentKey)
  }

  private func queuedSharedContent(from defaults: UserDefaults)
    -> [(key: String, value: String)]
  {
    let dictionary = defaults.dictionaryRepresentation()
    var entries = [(key: String, value: String, timestamp: TimeInterval)]()

    for (key, value) in dictionary {
      guard key.hasPrefix(sharedContentQueuePrefix),
            let stringValue = value as? String,
            let timestamp = parseTimestamp(from: key) else {
        continue
      }
      entries.append((key: key, value: stringValue, timestamp: timestamp))
    }

    entries.sort { $0.timestamp < $1.timestamp }

    return entries.map { ($0.key, $0.value) }
  }

  private func makeQueueEntryKey(timestamp: TimeInterval = Date().timeIntervalSince1970) -> String {
    return String(
      format: "%@%.6f_%@",
      sharedContentQueuePrefix,
      timestamp,
      UUID().uuidString
    )
  }

  private func parseTimestamp(from key: String) -> TimeInterval? {
    guard key.hasPrefix(sharedContentQueuePrefix) else {
      return nil
    }

    let startIndex = key.index(key.startIndex, offsetBy: sharedContentQueuePrefix.count)
    let remainder = key[startIndex...]
    guard let separatorIndex = remainder.firstIndex(of: "_") else {
      return nil
    }

    let timestampSubstring = remainder[..<separatorIndex]
    return Double(String(timestampSubstring))
  }
}

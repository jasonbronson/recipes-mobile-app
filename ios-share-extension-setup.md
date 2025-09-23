# iOS Share Extension Setup Guide

This guide outlines the necessary steps to configure the iOS Share Extension for the share_handler package to work properly with your Flutter app.

## 1. Add Share Extension Target

In Xcode, add a new Share Extension target to your iOS project:

1. Open your project in Xcode (ios/Runner.xcworkspace)
2. Go to **File > New > Target**
3. Select **Share Extension** from the iOS tab
4. Name it "ShareExtension" (or similar)
5. Choose SwiftUI or Storyboard (SwiftUI recommended for modern apps)
6. Finish the target creation

## 2. Configure App Groups

Both your main app and the Share Extension need to share data using App Groups:

### Main App Configuration:
1. Select your main app target in Xcode
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Create a new App Group ID: `group.com.yourcompany.yourapp.share`
6. Check the App Group checkbox

### Share Extension Configuration:
1. Select your Share Extension target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Select the same App Group ID: `group.com.yourcompany.yourapp.share`
6. Check the App Group checkbox

## 3. Configure Info.plist Files

### Main App Info.plist:
Add the following entries to support receiving shared content:

```xml
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeName</key>
        <string>All Files</string>
        <key>LSHandlerRank</key>
        <string>Alternate</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>public.content</string>
            <string>public.text</string>
            <string>public.url</string>
        </array>
    </dict>
</array>

<key>NSUserActivityTypes</key>
<array>
    <string>INSendMessageIntent</string>
</array>
```

### Share Extension Info.plist:
Configure what types of content the extension can handle:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <dict>
            <key>NSExtensionActivationSupportsText</key>
            <true/>
            <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
            <integer>1</integer>
        </dict>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
</dict>
```

## 4. Implement Share Extension Logic

Create a Swift file in your Share Extension to handle the shared content:

```swift
import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the shared content
        if let extensionContext = extensionContext,
           let inputItems = extensionContext.inputItems as? [NSExtensionItem] {
            for item in inputItems {
                if let attachments = item.attachments {
                    for attachment in attachments {
                        if attachment.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                            attachment.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (result, error) in
                                if let text = result as? String {
                                    // Store the shared text using App Groups
                                    self.storeSharedContent(text)
                                }
                            }
                        } else if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                            attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (result, error) in
                                if let url = result as? URL {
                                    // Store the shared URL using App Groups
                                    self.storeSharedContent(url.absoluteString)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func storeSharedContent(_ content: String) {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.yourapp.share")
        userDefaults?.set(content, forKey: "sharedContent")
        userDefaults?.synchronize()
    }

    override func didSelectPost() {
        // Complete the sharing
        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func didSelectCancel() {
        // Cancel the sharing
        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
}
```

## 5. Update Flutter App to Read from App Groups

In your Flutter app, you'll need to read from the shared UserDefaults:

```dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// For iOS App Groups, you might need a custom implementation
// or use a plugin that supports App Groups

class ShareHandlerService {
  static const String _appGroupId = 'group.com.recipe.bronson.dev.share';
  static const String _sharedContentKey = 'sharedContent';

  // This would require native iOS code or a plugin that supports App Groups
  Future<String?> getSharedContent() async {
    // Implementation depends on your App Groups setup
  }
}
```

## 6. Testing

1. Build and run your app on a device/simulator
2. From another app (Safari, Notes, etc.), use the Share button
3. Look for your app in the share sheet
4. Select your app to share content
5. Verify the content appears in your Flutter app

## 7. Important Notes

- **Bundle ID Matching**: Ensure your Share Extension has a bundle ID that matches your main app (e.g., `com.yourcompany.yourapp.shareextension`)
- **Provisioning Profiles**: Both targets need proper provisioning profiles with App Groups capability
- **Entitlements**: Xcode should automatically generate the entitlements files
- **Distribution**: When distributing, ensure both targets are included in your archive

## 8. Alternative: Use share_handler Package Native Implementation

The share_handler package already handles most of the native iOS setup. You mainly need to:

1. Add the App Groups capability to both targets
2. Configure the Info.plist files as described above
3. The package will handle the Share Extension implementation automatically

For detailed implementation, refer to the [share_handler package documentation](https://pub.dev/packages/share_handler).

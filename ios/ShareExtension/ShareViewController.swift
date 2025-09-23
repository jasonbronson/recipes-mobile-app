import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    private let appGroupId = "group.com.bronson.dev.iosapp"
    private let sharedContentKey = "sharedContent"
    private var hasCompletedRequest = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        processInputItems()
    }

    private func processInputItems() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            completeRequest()
            return
        }

        for item in items {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    handle(provider, type: .url)
                    return
                }

                if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                    handle(provider, type: .text)
                    return
                }
            }
        }

        completeRequest()
    }

    private func handle(_ provider: NSItemProvider, type: SharedType) {
        provider.loadItem(forTypeIdentifier: type.uniformTypeIdentifier, options: nil) { [weak self] item, error in
            guard let self else { return }

            if let error {
                NSLog("ShareExtension loadItem error: \(error.localizedDescription)")
            }

            guard let content = self.extractContent(from: item, type: type) else {
                self.completeRequest()
                return
            }

            self.storeSharedContent(content)
            self.openHostApp()
        }
    }

    private func extractContent(from item: NSSecureCoding?, type: SharedType) -> String? {
        switch type {
        case .url:
            if let url = item as? URL {
                return url.absoluteString
            }

            if let url = item as? NSURL {
                return url.absoluteString
            }

            if let data = item as? Data,
               let unarchivedURL = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSURL.self, from: data) {
                return unarchivedURL.absoluteString
            }

        case .text:
            if let string = item as? String {
                return string
            }

            if let string = item as? NSString {
                return string as String
            }

            if let data = item as? Data,
               let string = String(data: data, encoding: .utf8) {
                return string
            }
        }

        return nil
    }

    private func storeSharedContent(_ content: String) {
        let defaults = UserDefaults(suiteName: appGroupId)
        defaults?.set(content, forKey: sharedContentKey)
        defaults?.synchronize()
    }

    private func openHostApp() {
        guard let url = URL(string: "iosapp://shared") else {
            completeRequest()
            return
        }

        guard let context = extensionContext, !hasCompletedRequest else {
            completeRequest()
            return
        }

        hasCompletedRequest = true

        DispatchQueue.main.async {
            context.completeRequest(returningItems: [], completionHandler: { _ in
                DispatchQueue.main.async {
                    context.open(url, completionHandler: { success in
                        if !success {
                            NSLog("ShareExtension failed to open host app")
                        }
                    })
                }
            })
        }
    }

    private func completeRequest() {
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.hasCompletedRequest else { return }
            self.hasCompletedRequest = true
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}

private enum SharedType {
    case url
    case text

    var uniformTypeIdentifier: String {
        switch self {
        case .url:
            return UTType.url.identifier
        case .text:
            return UTType.text.identifier
        }
    }
}

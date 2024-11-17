import SwiftUI
import UniformTypeIdentifiers

class ShareModel: ObservableObject {
    @Published var sharedTags: String = ""
    @Published var sharedURL: URL?
    var extensionContext: NSExtensionContext?
    
    // App Groupに対応したUserDefaultsのインスタンス
    private let sharedUserDefaults = UserDefaults(suiteName: "group.strage")
    
    init() {}

    func configure(context: NSExtensionContext?) {
        self.extensionContext = context
        
        guard let item = context?.inputItems.first as? NSExtensionItem else { return }
        guard let itemProvider = item.attachments?.first else { return }
        
        // URLが共有された場合
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { data, error in
                guard let sharedURL = data as? URL else { return }
                DispatchQueue.main.async {
                    self.sharedURL = sharedURL
                }
            }
        }
    }
    
    func submit() {
        if let urlString = sharedURL?.absoluteString {
            print("correct input!")
            let tags = extractTags(from: sharedTags)
            addURL(urlString, tags: tags)
        } else {
            print("input error...")
        }
        self.extensionContext?.completeRequest(returningItems: nil) // 共有完了
    }
    
    func cancel() {
        self.extensionContext?.cancelRequest(withError: ShareError.cancel)
    }
    
    private func addURL(_ url: String, tags: [String]) {
        var savedURLs = sharedUserDefaults?.array(forKey: "urls") as? [String] ?? []
        var savedTags = sharedUserDefaults?.dictionary(forKey: "tags") as? [String: [String]] ?? [:]
        
        print("now start saving \(url)")
        // 新しいURLを保存
        savedURLs.append(url)
        NSLog("URLs saved: \(savedURLs)")
        sharedUserDefaults?.set(savedURLs, forKey: "urls")
        sharedUserDefaults?.synchronize()
        NSLog("URLs saved: \(savedURLs)")
        
        // 新しいタグをURLに紐づけて保存（複数タグを保存）
        savedTags[url] = tags
        sharedUserDefaults?.set(savedTags, forKey: "tags")
        sharedUserDefaults?.synchronize()
    }

    private func extractTags(from text: String) -> [String] {
        let words = text.split { $0 == " " || $0 == "　" }
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
        return words
    }
    
    enum ShareError: Error {
        case cancel
    }
}

import SwiftUI
import UniformTypeIdentifiers

class ShareModel: ObservableObject {
    @Published var sharedTags: String = ""
    @Published var sharedURL: URL?
    var extensionContext: NSExtensionContext?
    
    // App Groupの利用
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
    
    private func addURL(_ url: String, tags: [String], memo: String? = nil) {
        // 既存データの取得
        var savedURLs = sharedUserDefaults?.dictionary(forKey: "urls") as? [String: [String]] ?? [:]
        var savedInfo = sharedUserDefaults?.dictionary(forKey: "info") as? [String: [String: Any]] ?? [:]
        
        // 日時を取得
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: currentDate)
        
        // urls配列に新しい URL をタグごとに追加
        for tag in tags {
            if savedURLs[tag] == nil {
                savedURLs[tag] = []
            }
            if !savedURLs[tag]!.contains(url) {
                savedURLs[tag]!.append(url)
            }
        }
        
        // info配列に新しい URL 情報を追加
        savedInfo[url] = [
            "tags": tags,
            "date": dateString,
            "memo": memo ?? ""
        ]
        
        // データの保存
        sharedUserDefaults?.set(savedURLs, forKey: "urls")
        sharedUserDefaults?.set(savedInfo, forKey: "info")
        
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

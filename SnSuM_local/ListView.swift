import SwiftUI

struct YourListView: View {
    @State private var searchTag: String = ""
    @State private var urls: [String] = []
    @State private var isLoading: Bool = false
    @State private var selectedURL: URL? = nil

    // App Groups対応のUserDefaultsインスタンス
    private let sharedDefaults = UserDefaults(suiteName: "group.strage")

    var body: some View {
        VStack {
            // 検索バー
            HStack {
                TextField("Enter tag to search", text: $searchTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                Button(action: {
                    searchByTag()
                }) {
                    Text("Search")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()

            // ミニウィンドウ
            if let url = selectedURL {
                WebView(url: url)
                    .frame(height: 300)
                    .cornerRadius(8)
                    .padding()
            }

            // ローディングインジケーターまたはリスト表示
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if urls.isEmpty {
                Text("No URLs found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(urls, id: \.self) { url in
                    HStack {
                        Button(action: {
                            if let url = URL(string: url) {
                                selectedURL = url
                            }
                        }) {
                            Text(shortenURL(url))
                                .foregroundColor(.mint)
                                .lineLimit(1)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button(role: .destructive) {
                            deleteURL(url: url)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        ShareLink(item: URL(string: url)!) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .navigationTitle("Your List")
        .onAppear {
            displayAllURLs()
        }
    }

    private func searchByTag() {
        guard !searchTag.isEmpty else {
            displayAllURLs()
            return
        }

        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async {
            if let savedTags = self.sharedDefaults?.dictionary(forKey: "tags") as? [String: [String]] {
                let filteredURLs = savedTags.compactMap { key, tags in
                    tags.contains(self.searchTag) ? key : nil
                }
                
                DispatchQueue.main.async {
                    self.urls = filteredURLs
                    isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.urls = []
                    isLoading = false
                }
            }
        }
    }

    private func displayAllURLs() {
        if let savedTags = sharedDefaults?.dictionary(forKey: "tags") as? [String: [String]] {
            DispatchQueue.main.async {
                self.urls = Array(savedTags.keys)
            }
        } else {
            DispatchQueue.main.async {
                self.urls = []
            }
        }
    }

    private func shortenURL(_ url: String) -> String {
        url.count > 30 ? "\(url.prefix(30))..." : url
    }

    private func deleteURL(url: String) {
        // 削除前のデータをログ出力
        if let initialTags = sharedDefaults?.dictionary(forKey: "tags") as? [String: [String]] {
            print("Before deletion - Tags: \(initialTags)")
        } else {
            print("Before deletion - Tags: nil")
        }
        
        if let initialURLs = sharedDefaults?.array(forKey: "urls") as? [String] {
            print("Before deletion - URLs: \(initialURLs)")
        } else {
            print("Before deletion - URLs: nil")
        }

        // savedTags と savedURLs の取得
        guard var savedTags = sharedDefaults?.dictionary(forKey: "tags") as? [String: [String]] else {
            print("No saved tags found in UserDefaults.")
            return
        }
        
        guard var savedURLs = sharedDefaults?.array(forKey: "urls") as? [String] else {
            print("No saved URLs found in UserDefaults.")
            return
        }
        
        // URLを保存しているタグから削除
        for (tag, urls) in savedTags {
            if let index = urls.firstIndex(of: url) {
                savedTags[tag]?.remove(at: index)
                if savedTags[tag]?.isEmpty == true {
                    savedTags.removeValue(forKey: tag) // 完全に削除
                }
            }
        }
        
        // URLsリストから該当URLを削除
        if let index = savedURLs.firstIndex(of: url) {
            savedURLs.remove(at: index)
        } else {
            print("URL \(url) not found in the 'urls' list.")
        }
        
        // 既存のデータを完全に削除
        sharedDefaults?.removeObject(forKey: "tags")
        sharedDefaults?.removeObject(forKey: "urls")
        
        // 新しいデータを保存
        sharedDefaults?.set(savedTags, forKey: "tags")
        sharedDefaults?.set(savedURLs, forKey: "urls")
        
        // 削除後のデータをログ出力
        if let updatedTags = sharedDefaults?.dictionary(forKey: "tags") as? [String: [String]] {
            print("After deletion - Tags: \(updatedTags)")
        } else {
            print("After deletion - Tags: nil")
        }
        
        if let updatedURLs = sharedDefaults?.array(forKey: "urls") as? [String] {
            print("After deletion - URLs: \(updatedURLs)")
        } else {
            print("After deletion - URLs: nil")
        }

        // UIを確実に更新
        DispatchQueue.main.async {
            self.urls = [] // 一度リセット
            self.displayAllURLs() // 再ロード
        }
    }

}

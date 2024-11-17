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
            if let savedURLs = self.sharedDefaults?.dictionary(forKey: "urls") as? [String: [String]] {
                let filteredURLs = savedURLs.flatMap { (tag, urls) in
                    tag.contains(self.searchTag) ? urls : []
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
        if let savedURLs = sharedDefaults?.dictionary(forKey: "urls") as? [String: [String]] {
            DispatchQueue.main.async {
                self.urls = savedURLs.flatMap { $0.value }
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
        if let initialTags = sharedDefaults?.dictionary(forKey: "urls") as? [String: [String]] {
            print("Before deletion - Tags: \(initialTags)")
        } else {
            print("Before deletion - Tags: nil")
        }

        if let initialInfo = sharedDefaults?.dictionary(forKey: "info") as? [String: [String: Any]] {
            print("Before deletion - Info: \(initialInfo)")
        } else {
            print("Before deletion - Info: nil")
        }

        // `urls`と`info`のデータ取得
        guard var savedTags = sharedDefaults?.dictionary(forKey: "urls") as? [String: [String]] else {
            print("No saved tags found in UserDefaults.")
            return
        }
        
        guard var savedInfo = sharedDefaults?.dictionary(forKey: "info") as? [String: [String: Any]] else {
            print("No saved info found in UserDefaults.")
            return
        }

        // 1. `info`配列から該当URLを削除
        savedInfo.removeValue(forKey: url)

        // 2. `urls`配列内のタグから該当URLを削除
        for (tag, urls) in savedTags {
            if let index = urls.firstIndex(of: url) {
                savedTags[tag]?.remove(at: index)
                // URLが削除された後、タグ内にURLが残っていなければそのタグも削除
                if savedTags[tag]?.isEmpty == true {
                    savedTags.removeValue(forKey: tag)
                }
            }
        }

        // 3. `info`および`urls`の変更をUserDefaultsに保存
        sharedDefaults?.set(savedTags, forKey: "urls")
        sharedDefaults?.set(savedInfo, forKey: "info")

        // 削除後のデータをログ出力
        if let updatedTags = sharedDefaults?.dictionary(forKey: "urls") as? [String: [String]] {
            print("After deletion - Tags: \(updatedTags)")
        } else {
            print("After deletion - Tags: nil")
        }

        if let updatedInfo = sharedDefaults?.dictionary(forKey: "info") as? [String: [String: Any]] {
            print("After deletion - Info: \(updatedInfo)")
        } else {
            print("After deletion - Info: nil")
        }

        // 4. URL削除後にself.urlsを更新
        DispatchQueue.main.async {
            self.urls = [] // 一度リセット
            self.displayAllURLs() // 再ロードして画面を更新
        }
    }



}

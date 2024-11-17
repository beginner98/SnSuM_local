import SwiftUI

struct ContentView: View {
    @State private var searchTag: String = "" // 検索タグ入力用の状態
    @State private var urls: [String] = []    // 検索結果のURLを格納する配列
    @State private var isLoading: Bool = false // ローディング状態を管理
    @State private var selectedURL: URL? = nil
    
    // App Groupに対応したUserDefaultsのインスタンス
    private let sharedDefaults = UserDefaults(suiteName: "group.strage")

    var body: some View {
        NavigationView {
            VStack {
                // タグ検索バーと検索結果
                VStack {
                    HStack {
                        TextField("Enter tag to search", text: $searchTag)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                        Button(action: {
                            searchByTag()
                        }) {
                            Text("Search")
                                .padding()
                                .background(Color.black)
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
                
                Spacer() // 検索部分とボタン群の間に余白を追加
                
                // 画面遷移のボタン群
                HStack(spacing: 20) {
                    NavigationLink(destination: YourListView()) {
                        Image(systemName: "list.clipboard")
                            .fontWeight(.medium)
                            .frame(minWidth: 60)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    NavigationLink(destination: AddURLView()) {
                        Image(systemName: "plus.app")
                            .fontWeight(.medium)
                            .frame(minWidth: 60)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: OptionsView()) {
                        Image(systemName: "gearshape.fill")
                            .fontWeight(.medium)
                            .frame(minWidth: 60)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarHidden(true) // ナビゲーションバーを非表示にする
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
        
        guard var savedURLs = sharedDefaults?.dictionary(forKey: "urls") as? [String: [String]] else {
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
        
        // URLを保存している URLs 配列から削除
        for (tag, urls) in savedURLs {
            if let index = urls.firstIndex(of: url) {
                savedURLs[tag]?.remove(at: index)
                if savedURLs[tag]?.isEmpty == true {
                    savedURLs.removeValue(forKey: tag)
                }
            }
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
        
        if let updatedURLs = sharedDefaults?.dictionary(forKey: "urls") as? [String: [String]] {
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

#Preview {
    ContentView()
}

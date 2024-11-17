import SwiftUI

struct ContentView: View {
    @State private var searchTag: String = "" // 検索タグ入力用の状態
    @State private var urls: [String] = []    // 検索結果のURLを格納する配列
    @State private var isLoading: Bool = false // ローディング状態を管理
    @State private var selectedURL: URL? = nil
    
    // App Groupに対応したUserDefaultsのインスタンス
    private let sharedUserDefaults = UserDefaults(suiteName: "group.strage")

    var body: some View {
        NavigationView {
            VStack {
                // タグ検索バーと検索結果
                VStack {
                    HStack {
                        TextField("Enter tag to search", text: $searchTag)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                            searchByTag() // タグでの検索を実行
                        }) {
                            Image(systemName:"arrowshape.left.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .cornerRadius(10)
                                .background(Color.black)
                        }
                    }
                    .padding()
                    
                    // ミニウィンドウの表示
                    if let url = selectedURL {
                        WebView(url: url)
                            .frame(height: 300)
                            .cornerRadius(8)
                            .padding()
                    }
                    
                    // ローディングインジケーターまたは検索結果
                    if isLoading {
                        ProgressView("Loading...")
                    } else {
                        List(urls, id: \.self) { url in
                            Button(action: {
                                if let url = URL(string: url) {
                                    selectedURL = url
                                }
                            }) {
                                Text(url)
                                    .foregroundColor(.blue)
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
            .navigationTitle("SnSuM")
            .navigationBarHidden(true) // ナビゲーションバーを非表示にする
        }
    }

    private func searchByTag() {
        guard !searchTag.isEmpty else {
            self.urls = [] // 検索タグが空なら結果をクリア
            return
        }
        
        isLoading = true
        
        // ローカルデータを取得する処理
        if let savedTags = sharedUserDefaults?.dictionary(forKey: "tags") as? [String: [String]] {
            // タグに関連するURLのみをフィルタリング
            self.urls = savedTags.filter { $0.value.contains(searchTag) }.map { $0.key }
        }
        
        isLoading = false
    }
}

#Preview {
    ContentView()
}

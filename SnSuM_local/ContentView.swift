import SwiftUI
//スプラッシュ画面
struct SplashView: View {
    @State private var isActive = false
    var body: some View {
        VStack {
            if isActive {
                ContentView()
            } else {
                Text("SnSuM.")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .padding(.top, 50)
                    .onAppear {

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                isActive = true
                            }
                        }
                    }
            }
        }
        .transition(.opacity)
    }
}


struct ContentView: View {
    @State private var searchTag: String = "" // 検索タグ入力用の状態
    @State private var urls: [String] = []    // 検索結果のURLを格納する配列
    @State private var isLoading: Bool = false // ローディング状態を管理
    @State private var selectedURL: URL? = nil
    
    private let sharedDefaults = UserDefaults(suiteName: "group.strage") // Appgroupを使用

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                // タイトルとミニウィンドウの状態による変更
                VStack {
                    Text("SnSuM.")
                        .font(.system(size: selectedURL == nil ? 60 : 30))
                        .fontWeight(.bold)
                        .padding(.top, selectedURL == nil ? 50 : 10) // 上部スペース調整
                        .animation(.spring(), value: selectedURL)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                VStack {
                    HStack {
                        TextField("Enter tag to search", text: $searchTag)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 44)
                            .padding(.leading)
                        Button(action: {
                            hideKeyboard()
                            searchByTag()
                        }) {
                            Text("Search")
                                .frame(height: 44)
                                .padding(.horizontal)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()

                    // ミニウィンドウ
                    if let url = selectedURL {
                        ZStack(alignment: .topTrailing) {
                            WebView(url: url)
                                .frame(height: 300)
                                .cornerRadius(8)
                                .padding()

                            // 閉じるボタン
                            Button(action: {
                                selectedURL = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .padding([.top, .trailing], 10)
                            }
                        }
                    }

                    // ローディングまたはリスト表示
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else if urls.isEmpty {
                        Text("No URLs found.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        VStack {
                            List {
                                ForEach(urls, id: \.self) { url in
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
                            .scrollContentBackground(.hidden) // デフォルト背景の非表示
                            .background(Color.white)
                        }
                    }
                }
                .padding(.bottom, 50)

                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarHidden(true) // ナビゲーションバーを非表示
            .overlay(
                // AddURLViewボタンを画面左上に配置
                NavigationLink(destination: AddURLView()) {
                    Image(systemName: "plus.app")
                        .font(.title)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .padding(.leading, 20),
                alignment: .topLeading
            )
            .overlay(
                // OptionsViewボタンを画面右上に配置
                NavigationLink(destination: OptionsView()) {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .padding(.trailing, 20),
                alignment: .topTrailing
            )
            .onAppear {
                // 初期表示時に日付順で最新5件のURLを表示
                loadLatestURLs()
            }
        }
    }

    // 初期表示時に日付順で最新5件のURLを表示
    private func loadLatestURLs() {
        // info配列を取得して、URLを日付順に並べ替えて最新の5件を取得
        if let savedInfo = sharedDefaults?.dictionary(forKey: "info") as? [String: [String: Any]] {
            let sortedURLs = savedInfo.keys.sorted { (url1, url2) -> Bool in
                if let date1 = savedInfo[url1]?["date"] as? Date,
                   let date2 = savedInfo[url2]?["date"] as? Date {
                    return date1 > date2
                }
                return false
            }
            let latestURLs = Array(sortedURLs.prefix(5))
            
            DispatchQueue.main.async {
                self.urls = latestURLs
            }
        } else {
            DispatchQueue.main.async {
                self.urls = []
            }
        }
    }

    private func searchByTag() {
        guard !searchTag.isEmpty else {
            // 検索タグが空の場合は全URLを表示
            loadLatestURLs()
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

        // info配列から該当URLを削除
        savedInfo.removeValue(forKey: url)

        // urls配列内のタグから該当URLを削除
        for (tag, urls) in savedTags {
            if let index = urls.firstIndex(of: url) {
                savedTags[tag]?.remove(at: index)
                // URLが削除された後、タグ内にURLが残っていなければそのタグも削除
                if savedTags[tag]?.isEmpty == true {
                    savedTags.removeValue(forKey: tag)
                }
            }
        }
        sharedDefaults?.removeObject(forKey: "urls")
        sharedDefaults?.removeObject(forKey: "info")
        // infoとurlsの変更をUserDefaultsに保存
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

        // URL削除後にself.urlsを更新
        DispatchQueue.main.async {
            self.urls = []
            self.loadLatestURLs() // 再ロードして画面を更新
        }
    }
    private func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
}

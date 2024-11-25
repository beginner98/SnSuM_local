import SwiftUI

struct AddURLView: View {
    @State private var inputURL: String = ""
    @State private var inputText: String = "" // ユーザーが入力するテキスト（タグ）
    @Environment(\.presentationMode) var presentationMode // 現在のビューを閉じるため
    
    // App Groupの利用
    private let sharedUserDefaults = UserDefaults(suiteName: "group.strage")

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                Text("Add URL")
                    .font(.title)
                    .padding()
                
                // URL入力フィールドとペーストボタン
                HStack {
                    TextField("Enter URL", text: $inputURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .frame(height: 50)
                    
                    // クリップボードからペーストするボタン
                    Button(action: {
                        if let url = UIPasteboard.general.string {
                            inputURL = url
                        }
                    }) {
                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                .padding(.horizontal)

                // テキスト入力フィールド
                TextField("tags", text: $inputText) // テキスト入力欄
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(height: 50)
                
                // 保存ボタン
                Button(action: {
                    // URLとタグが入力されていればローカルに保存
                    if !inputURL.isEmpty {
                        let tags = extractTags(from: inputText) // 空白区切りでタグを抽出
                        addURL(inputURL, tags: tags)
                    }
                }) {
                    Text("Save URL")
                        .fontWeight(.medium)
                        .frame(minWidth: 160)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                // キャンセルボタン
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // キャンセル時に画面を閉じる
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                        .frame(minWidth: 160)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarHidden(true)
    }
    
    // URLとタグを追加
    private func addURL(_ url: String, tags: [String], memo: String? = nil) {
        // 既存データの取得
        var savedURLs = sharedUserDefaults?.dictionary(forKey: "urls") as? [String: [String]] ?? [:]
        var savedInfo = sharedUserDefaults?.dictionary(forKey: "info") as? [String: [String: Any]] ?? [:]
        
        // 日時を取得
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: currentDate)
        
        // `urls` 配列に新しい URL をタグごとに追加
        for tag in tags {
            if savedURLs[tag] == nil {
                savedURLs[tag] = []
            }
            if !savedURLs[tag]!.contains(url) {
                savedURLs[tag]!.append(url)
            }
        }
        
        // `info` 配列に新しい URL 情報を追加
        savedInfo[url] = [
            "tags": tags,
            "date": dateString,
            "memo": memo ?? ""
        ]
        
        // データの保存
        sharedUserDefaults?.set(savedURLs, forKey: "urls")
        sharedUserDefaults?.set(savedInfo, forKey: "info")
        
        // 追加後に画面を閉じる
        presentationMode.wrappedValue.dismiss()
        print("URL added successfully!")
    }

    // 入力されたテキストから空白区切りのタグを抽出
    private func extractTags(from text: String) -> [String] {
        // 半角スペースと全角スペースで区切る
        let words = text.split { $0 == " " || $0 == "　" }
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty } // 空のタグは無視
        return words // 空白区切りの単語をそのままタグとして返す
    }
}

struct AddURLView_Previews: PreviewProvider {
    static var previews: some View {
        AddURLView()
    }
}

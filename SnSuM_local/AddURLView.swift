import SwiftUI

struct AddURLView: View {
    @State private var inputURL: String = ""
    @State private var inputText: String = "" // ユーザーが入力するテキスト（タグ）
    @Environment(\.presentationMode) var presentationMode // 現在のビューを閉じるため
    
    // App Groupに対応したUserDefaultsのインスタンス
    private let sharedUserDefaults = UserDefaults(suiteName: "group.strage")

    var body: some View {
        VStack {
            Text("Add URL")
                .font(.title)
                .padding()
            
            // URL入力フィールド
            TextField("Enter URL", text: $inputURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(height: 50)
            
            // テキスト入力フィールド（空白区切りのタグ）
            TextField("Enter tags (separate by spaces)", text: $inputText) // テキスト入力欄
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
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
            .padding()
            
            // キャンセルボタン
            Button(action: {
                presentationMode.wrappedValue.dismiss() // キャンセル時に画面を閉じる
            }) {
                Text("Cancel")
                    .foregroundColor(.red)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    // ローカルでURLとタグを追加
    private func addURL(_ url: String, tags: [String]) {
        var savedURLs = sharedUserDefaults?.array(forKey: "urls") as? [String] ?? []
        var savedTags = sharedUserDefaults?.dictionary(forKey: "tags") as? [String: [String]] ?? [:]
        
        // 新しいURLを保存
        savedURLs.append(url)
        sharedUserDefaults?.set(savedURLs, forKey: "urls")
        
        // 新しいタグをURLに紐づけて保存（複数タグを保存）
        savedTags[url] = tags
        sharedUserDefaults?.set(savedTags, forKey: "tags")
        
        // 追加後に画面を閉じる
        presentationMode.wrappedValue.dismiss()
        print("URL added successfully!")
    }

    // 入力されたテキストから空白区切りのタグを抽出するメソッド
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

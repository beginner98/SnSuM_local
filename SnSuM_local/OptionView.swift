import SwiftUI

struct OptionsView: View {
    @State private var showingResetAlert = false // ダイアログの表示状態を管理
    @State private var showAllTags = false // "show All Tags" がタップされたかどうか
    @State private var tags: [String] = [] // 保存されているタグを格納する配列
    // App Groupの利用
    private let sharedUserDefaults = UserDefaults(suiteName: "group.strage")
    
    var body: some View {
        VStack {
            // タグ一覧表示ボタン
            Button(action: {
                // urlsに保存されているすべてのタグ名（キー）を取得
                if let savedUrls = sharedUserDefaults?.dictionary(forKey: "urls") as? [String: [String]] {
                    tags = Array(savedUrls.keys) // タグ名（キー）を配列に変換
                }
                showAllTags = true
            }) {
                Text("Show All Tags")
                    .fontWeight(.medium)
                    .frame(minWidth: 160)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            
            // 全消去ボタン
            Button(action: {
                showingResetAlert = true // ダイアログを表示
            }) {
                Text("Reset All")
                    .fontWeight(.medium)
                    .frame(minWidth: 160)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.red)
                    .cornerRadius(8)
            }

            // タグのリスト表示
            if showAllTags {
                Spacer() // 他の要素を下部に配置するためのスペーサー
                VStack(alignment: .leading) {
                    Text("Saved Tags")
                        .font(.title)
                        .padding(.top)
                    
                    // 保存されているタグ名（キー）をリスト表示
                    List(tags, id: \.self) { tag in
                        Text(tag)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.top, 20)
                .transition(.move(edge: .bottom)) // アニメーション
            }
        }
        .navigationTitle("Options")
        .alert(isPresented: $showingResetAlert) {
            // 確認ダイアログ
            Alert(
                title: Text("Are you sure?"),
                message: Text("This will reset all saved data."),
                primaryButton: .destructive(Text("Reset")) {
                    resetAllData() // データをリセットする処理を呼び出し
                },
                secondaryButton: .cancel()
            )
        }
        .padding()
    }
    
    // App Groupに保存されたデータを削除する処理
    private func resetAllData() {
        guard let sharedDefaults = sharedUserDefaults else {
            return
        }
        
        // App GroupのUserDefaultsから全てのデータを削除
        sharedDefaults.removeObject(forKey: "urls")
        sharedDefaults.removeObject(forKey: "info")
    }
}

#Preview {
    OptionsView()
}

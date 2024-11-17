import SwiftUI

struct OptionsView: View {
    @State private var showingResetAlert = false // ダイアログの表示状態を管理
    // App Groupに対応したUserDefaultsのインスタンス
    private let sharedUserDefaults = UserDefaults(suiteName: "group.strage")
    
    var body: some View {
        VStack {
            Button(action: {
                // All Tagsボタンのアクション
            }) {
                Text("All Tags")
                    .fontWeight(.medium)
                    .frame(minWidth: 160)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            
            Button(action: {
                // delete Tagsボタンのアクション
            }) {
                Text("Delete Tags")
                    .fontWeight(.medium)
                    .frame(minWidth: 160)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            
            // Reset Allボタン
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
    }
    
    // App Groupに保存されたデータを削除する処理
    private func resetAllData() {
        guard let sharedDefaults = sharedUserDefaults else {
            print("Failed to access shared UserDefaults.")
            return
        }
        
        // App GroupのUserDefaultsから全てのデータを削除
        sharedDefaults.removeObject(forKey: "urls")
        sharedDefaults.removeObject(forKey: "tags")
        
        // 完了したことをコンソールに表示
        print("All App Group data has been reset!")
    }
}

#Preview {
    OptionsView()
}

import SwiftUI

// ShareSheetから開かれる画面の構成
struct ShareView: View {
    @ObservedObject var model: ShareModel
    var dismiss: () -> Void

    var body: some View {
        NavigationView {
            Form {
                if let url = model.sharedURL {
                    Section(header: Text("URL")) {
                        Text(url.absoluteString)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Tags")) {
                    TextField("Enter tags (separated by spaces)", text: $model.sharedTags)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        model.cancel()
                    } label: {
                        Text("終了")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        NSLog("Submit button tapped")
                        model.submit()
                    } label: {
                        Text("保存")
                    }
                }

            }
            .navigationTitle("Share URL")
        }
    }
}

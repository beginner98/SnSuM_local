import UIKit
import SwiftUI

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ShareModelインスタンスを作成
        let shareModel = ShareModel()
        shareModel.configure(context: extensionContext) // NSExtensionContextを渡す
        
        // ShareView (SwiftUI) を作成し、dismissing logicを追加
        let shareView = ShareView(model: shareModel) {
            self.dismiss(animated: true, completion: nil)
        }
        
        // UIHostingControllerを使ってSwiftUIビューをラップ
        let hostingController = UIHostingController(rootView: shareView)
        
        // ビュー階層に追加
        addChild(hostingController)
        hostingController.view.frame = self.view.bounds
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    // isContentValid() をオーバーライドしてコンテンツの検証
    func isContentValid() -> Bool {
        return true
    }

    // didSelectPost() をオーバーライドして、ポスト後に処理を行います。
    func didSelectPost() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}

import UIKit
import SwiftUI

//拡張機能ShareExtentionを使用するための設定
class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ShareModelインスタンスを作成
        let shareModel = ShareModel()
        shareModel.configure(context: extensionContext) // NSExtensionContextを渡す
 
        let shareView = ShareView(model: shareModel) {
            self.dismiss(animated: true, completion: nil)
        }

        let hostingController = UIHostingController(rootView: shareView)
        
        // ビュー階層に追加
        addChild(hostingController)
        hostingController.view.frame = self.view.bounds
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    

    func isContentValid() -> Bool {
        return true
    }

    func didSelectPost() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}

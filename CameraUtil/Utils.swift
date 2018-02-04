import UIKit

class Utils: NSObject {
    
    class func appName() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    class func displayAlertView(viewController: UIViewController, title: String, message: String, action: UIAlertAction?) {
        let alert = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        
        if action == nil {
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        } else {
            alert.addAction(action!)
        }
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }

}

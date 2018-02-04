import UIKit
import AVFoundation
import Photos

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: self, comment: "")
    }
}

protocol CameraManagerDelegate {
    func imagePicker(image: UIImage, sourceType:  UIImagePickerControllerSourceType)
}

class CameraManager: NSObject {
    
    var viewControllerDelegate : UIViewController
    
    init(viewController : UIViewController) {
        viewControllerDelegate = viewController
    }
    
    func cameraRequest() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            checkCameraAccess(for: .video)
        }
    }
    
    func checkCameraAccess(for mediaType : AVMediaType) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        
        switch cameraAuthorizationStatus {
        case .denied:
            alertPromptToAllowAccessViaSettings()
            break
        case .authorized:
            openCamera()
            break
        case .restricted:
            break
        case .notDetermined:
            getCameraAccess(for: .video)
            break
        }
    }
    
    func getCameraAccess(for mediaType : AVMediaType) {
        AVCaptureDevice.requestAccess(for: mediaType) { granted in
            if granted {
                self.openCamera()
            }
        }
    }
    
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        viewControllerDelegate.present(imagePicker, animated: true, completion: nil)
    }
    
    func libraryRequest() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            checkLibraryAccess()
        }
    }
    
    func checkLibraryAccess()  {
        let libraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch libraryAuthorizationStatus {
        case .denied:
            alertPromptToAllowAccessViaSettings()
            break
        case .authorized:
            openLibrary()
            break
        case .restricted:
            break
        case .notDetermined:
            getLibraryAccess()
            break
        }
    }

    func getLibraryAccess() {
        PHPhotoLibrary.requestAuthorization({ authorizationStatus in
            if authorizationStatus == .authorized {
                self.openLibrary()
            }
        })
    }
    
    func openLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary;
        imagePicker.allowsEditing = true
        viewControllerDelegate.present(imagePicker, animated: true, completion: nil)
    }
    
    func alertPromptToAllowAccessViaSettings() {
        let action = UIAlertAction(title: "open_settings".localized(), style: .cancel) { alert in
            if let urlObj = NSURL.init(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(urlObj as URL, options: [ : ], completionHandler: nil)
            }
        }
        
        Utils.displayAlertView(viewController: self.viewControllerDelegate,
                               title: String(format: "camera_access".localized(), Utils.appName()),
                               message: "camera_permission".localized(),
                               action: action)
    }
}

extension CameraManager: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var image : UIImage?
        if picker.isEditing {
            image = info[UIImagePickerControllerEditedImage] as? UIImage
        } else {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if let viewController = viewControllerDelegate as? CameraManagerDelegate, let img = image {
            viewController.imagePicker(image: img, sourceType: picker.sourceType)
        }
    }
}

extension CameraManager: UINavigationControllerDelegate {
    
}

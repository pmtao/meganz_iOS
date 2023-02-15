
import Foundation
import MEGADomain
import MEGAPresentation

@objc enum CustomModalAlertMode: Int {
    case storageEvent = 0
    case storageQuotaError
    case storageUploadQuotaError
    case storageDownloadQuotaError
    case businessGracePeriod
    case outgoingContactRequest
    case contactNotInMEGA
    case enableKeyRotation
    case upgradeSecurity
}

@objc class CustomModalAlertRouter: NSObject, Routing {
    
    private weak var presenter: UIViewController?
    
    internal var mode: CustomModalAlertMode
    
    private var chatId: ChatIdEntity?
    
    @objc init(_ mode: CustomModalAlertMode, presenter: UIViewController) {
        self.mode = mode
        self.presenter = presenter
    }
    
    init(_ mode: CustomModalAlertMode, presenter: UIViewController, chatId: ChatIdEntity) {
        self.mode = mode
        self.presenter = presenter
        self.chatId = chatId
    }
    
    func build() -> UIViewController {
        let customModalAlertVC = CustomModalAlertViewController()
        switch mode {
        case .storageQuotaError:
            customModalAlertVC.configureForStorageQuotaError(false)
            
        case .storageUploadQuotaError:
            customModalAlertVC.configureForStorageQuotaError(true)
            
        case .storageDownloadQuotaError:
            customModalAlertVC.configureForStorageDownloadQuotaError()
            
        case .businessGracePeriod:
            customModalAlertVC.configureForBusinessGracePeriod()
            
        case .enableKeyRotation:
            guard let chatId else { return customModalAlertVC }
            customModalAlertVC.configureForEnableKeyRotation(in: chatId)
        
        case .upgradeSecurity:
            customModalAlertVC.configureForUpgradeSecurity()
            
        default: break
        }
        
        return customModalAlertVC
    }
    
    @objc func start() {
        let visibleViewController = UIApplication.mnz_visibleViewController()
        if mode != .upgradeSecurity &&
            (visibleViewController is CustomModalAlertViewController ||
             visibleViewController is UpgradeTableViewController ||
             visibleViewController is ProductDetailViewController) {
            return
        }
        
        presenter?.present(build(), animated: true, completion: nil)
    }
}

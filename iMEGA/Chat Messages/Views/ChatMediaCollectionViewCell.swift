import MessageKit

class ChatMediaCollectionViewCell: MessageContentCell, MEGATransferDelegate {
    
    var currentNode : MEGANode?
    open var imageView: YYAnimatedImageView = {
        let imageView = YYAnimatedImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    open var playIconView: UIImageView = {
        let playIconView = UIImageView(image: UIImage(named: "playButton"))
        return playIconView
    }()
    
    open var durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.mnz_SFUIRegular(withSize: 12)
        label.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 1
        return label
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        MEGASdkManager.sharedMEGASdk()?.add(self)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        MEGASdkManager.sharedMEGASdk()?.add(self)
    }
    
    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
        imageView.autoPinEdgesToSuperviewEdges()
        playIconView.autoCenterInSuperview()
        durationLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        durationLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        durationLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        durationLabel.autoSetDimension(.height, toSize: 14)
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(imageView)
        imageView.addSubview(playIconView)
        imageView.addSubview(durationLabel)
        setupConstraints()
    }
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let chatMessage = message as? ChatMessage else {
            return
        }

        let megaMessage = chatMessage.message
        let node = megaMessage.nodeList.node(at: 0)!
        currentNode = node
        let name = node.name! as NSString
        
        self.imageView.mnz_setPreview(by: node) {(request) in
            messagesCollectionView.reloadItems(at: [indexPath])
        }
        
        durationLabel.isHidden = true
        playIconView.isHidden = true
        
        if name.pathExtension == "gif" {
            let originalImagePath = Helper.path(for: node, inSharedSandboxCacheDirectory: "originalV3")
            if FileManager.default.fileExists(atPath: originalImagePath) {
                imageView.yy_imageURL = URL(fileURLWithPath: originalImagePath)
                return
            }
            MEGASdkManager.sharedMEGASdk()?.startDownloadTopPriority(with: node, localPath: originalImagePath, appData: nil)
        } else if name.mnz_isVideoPathExtension {
            durationLabel.text = NSString.mnz_string(fromTimeInterval: TimeInterval(node.duration))
            durationLabel.isHidden = false
            playIconView.isHidden = false
            
        }
        
        
    }
    
    func onTransferFinish(_ api: MEGASdk, transfer: MEGATransfer, error: MEGAError) {
        if currentNode?.handle == transfer.nodeHandle {
            if FileManager.default.fileExists(atPath: transfer.path) {
                imageView.yy_imageURL = URL(fileURLWithPath: transfer.path)
            }
        }
    }
}

open class ChatMediaCollectionViewSizeCalculator: MessageSizeCalculator {
   
    let cell = ChatMediaCollectionViewCell()

    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init(layout: layout)
        configureAccessoryView()
    }
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        switch message.kind {
        case .custom:
            let maxWidth = messageContainerMaxWidth(for: message)
            let maxHeight = UIDevice.current.mnz_maxSideForChatBubble(withMedia: true)
            guard let chatMessage = message as? ChatMessage else {
                return .zero
            }
           
            let megaMessage = chatMessage.message
            let node = megaMessage.nodeList.node(at: 0)!
            let previewFilePath = Helper.path(for: node, inSharedSandboxCacheDirectory: "previewsV3")
         
            var width: CGFloat = 200
            var height: CGFloat = 200

            if FileManager.default.fileExists(atPath: previewFilePath) {
                let previewImage = YYImage(contentsOfFile: previewFilePath)
                width = previewImage!.size.width
                height = previewImage!.size.height
            }
            if node.hasPreview() &&
                node.height > 0 &&
                node.width > 0 {
                width = CGFloat(node.width)
                height = CGFloat(node.height)
            }
            
            let ratio = width / height
            if ratio > 1 {
                width = min(maxWidth, width)
                height = width / ratio
            } else {
                height = min(maxHeight, height)
                width = height * ratio
            }
            
            return CGSize(width: width, height: height)
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }
}

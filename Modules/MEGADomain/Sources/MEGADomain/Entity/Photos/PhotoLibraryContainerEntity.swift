import Foundation

public struct PhotoLibraryContainerEntity {
    public let cameraUploadNode: NodeEntity?
    public let mediaUploadNode: NodeEntity?
    
    public init(cameraUploadNode: NodeEntity?, mediaUploadNode: NodeEntity?) {
        self.cameraUploadNode = cameraUploadNode
        self.mediaUploadNode = mediaUploadNode
    }
}

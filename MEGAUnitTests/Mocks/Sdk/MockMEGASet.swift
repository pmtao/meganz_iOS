import Foundation
@testable import MEGA
import MEGADomain

final class MockMEGASet: MEGASet {
    private let setHandle: HandleEntity
    private let setUserId: HandleEntity
    private let setCoverId: HandleEntity
    private let setName: String
    private let setChangeType: MEGASetChangeType
    private var setModificationTime: Date
    
    override var handle: UInt64 { setHandle }
    override var userId: UInt64 { setUserId }
    override var cover: UInt64 { setCoverId }
    override var name: String? { setName }
    override var timestamp: Date { setModificationTime }
    
    init(handle: HandleEntity,
         userId: HandleEntity,
         coverId: HandleEntity,
         name: String = "",
         changeType: MEGASetChangeType = .new,
         modificationTime: Date = Date()) {
        setHandle = handle
        setUserId = userId
        setCoverId = coverId
        setName = name
        setChangeType = changeType
        setModificationTime = modificationTime
        
        super.init()
    }
}

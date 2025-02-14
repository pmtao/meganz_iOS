import Foundation

public struct SetElementEntity: Hashable, Sendable {
    public let handle: HandleEntity
    public let ownerId: HandleEntity
    public let order: HandleEntity
    public let nodeId: HandleEntity
    public let modificationTime: Date
    public let name: String
    
    public init(handle: HandleEntity, ownerId: HandleEntity, order: HandleEntity,
                nodeId: HandleEntity, modificationTime: Date, name: String) {
        self.handle = handle
        self.ownerId = ownerId
        self.order = order
        self.nodeId = nodeId
        self.modificationTime = modificationTime
        self.name = name
    }
}

extension SetElementEntity: Identifiable {
    public var id: HandleEntity { handle }
}

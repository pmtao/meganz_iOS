@testable import MEGA
import Combine
import MEGADomain

struct MockChatRoomUseCase: ChatRoomUseCaseProtocol {
    var publicLinkCompletion: Result<String, ChatLinkErrorEntity> = .failure(.generic)
    var createChatRoomCompletion: Result<ChatRoomEntity, ChatRoomErrorEntity>?
    var chatRoomEntity: ChatRoomEntity?
    var renameChatRoomCompletion: Result<String, ChatRoomErrorEntity> = .failure(.generic)
    var myPeerHandles: [HandleEntity] = []
    var participantsUpdatedSubject = PassthroughSubject<[HandleEntity], Never>()
    var privilegeChangedSubject = PassthroughSubject<HandleEntity, Never>()
    var peerPrivilege: ChatRoomPrivilegeEntity = .unknown
    var allowNonHostToAddParticipantsEnabled = false
    var allowNonHostToAddParticipantsValueChangedSubject = PassthroughSubject<Bool, Never>()
    var userStatusEntity = ChatStatusEntity.invalid
    var message: ChatMessageEntity? = nil
    var contactEmail: String? = nil
    var base64Handle: String? = nil
    var messageSeenChatId: ((ChatIdEntity) -> Void)? = nil
    var archivedChatId: ((ChatIdEntity, Bool) -> Void)? = nil
    var closePreviewChatId: ((ChatIdEntity) -> Void)? = nil
    var leaveChatRoomSuccess = false
    var ownPrivilegeChangedSubject = PassthroughSubject<HandleEntity, Never>()
    var updatedChatPrivilege: ((HandleEntity, ChatRoomPrivilegeEntity) -> Void)? = nil
    var invitedToChat: ((HandleEntity) -> Void)? = nil
    var removedFromChat: ((HandleEntity) -> Void)? = nil

    func chatRoom(forUserHandle userHandle: UInt64) -> ChatRoomEntity? {
        return chatRoomEntity
    }
    
    func chatRoom(forChatId chatId: UInt64) -> ChatRoomEntity? {
        return chatRoomEntity
    }
    
    func peerPrivilege(forUserHandle userHandle: HandleEntity, chatRoom: ChatRoomEntity) -> ChatRoomPrivilegeEntity? {
        peerPrivilege
    }

    func peerHandles(forChatRoom chatRoom: ChatRoomEntity) -> [HandleEntity] {
        myPeerHandles
    }
    
    func createChatRoom(forUserHandle userHandle: HandleEntity, completion: @escaping (Result<ChatRoomEntity, ChatRoomErrorEntity>) -> Void) {
        if let completionBlock = createChatRoomCompletion {
            completion(completionBlock)
        }
    }
    
    func fetchPublicLink(forChatRoom chatRoom: ChatRoomEntity, completion: @escaping (Result<String, ChatLinkErrorEntity>) -> Void) {
        completion(publicLinkCompletion)
    }
    
    func renameChatRoom(_ chatRoom: ChatRoomEntity, title: String, completion: @escaping (Result<String, ChatRoomErrorEntity>) -> Void) {
        completion(renameChatRoomCompletion)
    }
    
    func participantsUpdated(forChatRoom chatRoom: ChatRoomEntity) -> AnyPublisher<[HandleEntity], Never> {
        participantsUpdatedSubject.eraseToAnyPublisher()
    }
    
    func userStatus(forUserHandle userHandle: HandleEntity) -> ChatStatusEntity {
        userStatusEntity
    }
    
    func message(forChatRoom chatRoom: ChatRoomEntity, messageId: HandleEntity) -> ChatMessageEntity? {
        message
    }
    
    func archive(_ archive: Bool, chatRoom: ChatRoomEntity) {
        archivedChatId?(chatRoom.chatId, archive)
    }
    
    func setMessageSeenForChat(forChatRoom chatRoom: ChatRoomEntity, messageId: HandleEntity) {
        messageSeenChatId?(chatRoom.chatId)
    }
    
    func base64Handle(forChatRoom chatRoom: ChatRoomEntity) -> String? {
        base64Handle
    }
    
    func contactEmail(forUserHandle userHandle: HandleEntity) -> String? {
        contactEmail
    }
    
    func userPrivilegeChanged(forChatRoom chatRoom: ChatRoomEntity) -> AnyPublisher<HandleEntity, Never> {
        privilegeChangedSubject.eraseToAnyPublisher()
    }
    
    func allowNonHostToAddParticipants(_ enabled: Bool, forChatRoom chatRoom: ChatRoomEntity) async throws -> Bool {
        allowNonHostToAddParticipantsEnabled
    }
    
    func allowNonHostToAddParticipantsValueChanged(forChatRoom chatRoom: ChatRoomEntity) -> AnyPublisher<Bool, Never> {
        allowNonHostToAddParticipantsValueChangedSubject.eraseToAnyPublisher()
    }
    
    func closeChatRoomPreview(chatRoom: ChatRoomEntity) {
        closePreviewChatId?(chatRoom.chatId)
    }
    
    func leaveChatRoom(chatRoom: ChatRoomEntity) async -> Bool {
        leaveChatRoomSuccess
    }
    
    func ownPrivilegeChanged(forChatRoom chatRoom: ChatRoomEntity) -> AnyPublisher<HandleEntity, Never> {
        ownPrivilegeChangedSubject.eraseToAnyPublisher()
    }
    
    func updateChatPrivilege(chatRoom: ChatRoomEntity, userHandle: HandleEntity, privilege: ChatRoomPrivilegeEntity) {
        updatedChatPrivilege?(userHandle, privilege)
    }
    
    func invite(toChat chat: ChatRoomEntity, userId: HandleEntity) {
        invitedToChat?(userId)
    }
    
    func remove(fromChat chat: ChatRoomEntity, userId: HandleEntity) {
        removedFromChat?(userId)
    }
}

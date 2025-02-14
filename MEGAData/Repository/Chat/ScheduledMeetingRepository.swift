import MEGADomain
import Combine

public final class ScheduledMeetingRepository: ScheduledMeetingRepositoryProtocol {
    private let chatSDK: MEGAChatSdk
    
    public init(chatSDK: MEGAChatSdk) {
        self.chatSDK = chatSDK
    }
    
    public func scheduledMeetings() -> [ScheduledMeetingEntity] {
        chatSDK
            .getAllScheduledMeetings()
            .compactMap { scheduledMeeting in
                guard !scheduledMeeting.isCancelled,
                      let chatRoom = chatSDK.chatRoom(forChatId: scheduledMeeting.chatId),
                      !chatRoom.isArchived, chatRoom.ownPrivilege.toOwnPrivilegeEntity().isUserInChat else {
                    return nil
                }
                return scheduledMeeting.toScheduledMeetingEntity()
            }
    }
    
    public func scheduledMeetingsByChat(chatId: ChatIdEntity) -> [ScheduledMeetingEntity] {
        chatSDK
            .scheduledMeetings(byChat: chatId)
            .compactMap {
                $0.toScheduledMeetingEntity()
            }
    }
    
    public func scheduledMeeting(for scheduledMeetingId: ChatIdEntity, chatId: ChatIdEntity) -> ScheduledMeetingEntity? {
        chatSDK.scheduledMeeting(chatId, scheduledId: scheduledMeetingId).toScheduledMeetingEntity()
    }
    
    public func scheduledMeetingOccurrencesByChat(chatId: ChatIdEntity) async throws -> [ScheduledMeetingOccurrenceEntity] {
        try Task.checkCancellation()
        return try await withCheckedThrowingContinuation { continuation in
            chatSDK
                .fetchScheduledMeetingOccurrences(byChat: chatId, delegate: MEGAChatGenericRequestDelegate { request, error in
                    guard Task.isCancelled == false else {
                        continuation.resume(throwing: CancellationError())
                        return
                    }

                    guard error.type == .MEGAChatErrorTypeOk else {
                        continuation.resume(throwing: ChatRoomErrorEntity.noChatRoomFound)
                        return
                    }
                    
                    let occurrences = request.chatScheduledMeetingOccurrences.map { $0.toScheduledMeetingOccurrenceEntity() }
                    
                    continuation.resume(returning: occurrences)
                })
        }
    }
    
    public func scheduledMeetingOccurrencesByChat(chatId: ChatIdEntity, since: Date) async throws -> [ScheduledMeetingOccurrenceEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            guard Task.isCancelled == false else {
                continuation.resume(throwing: CancellationError())
                return
            }
            chatSDK
                .fetchScheduledMeetingOccurrences(byChat: chatId, since: UInt64(since.timeIntervalSince1970), delegate: MEGAChatGenericRequestDelegate { request, error in
                    guard Task.isCancelled == false else {
                        continuation.resume(throwing: CancellationError())
                        return
                    }

                    guard error.type == .MEGAChatErrorTypeOk else {
                        continuation.resume(throwing: ChatRoomErrorEntity.noChatRoomFound)
                        return
                    }
                    
                    let occurrences = request.chatScheduledMeetingOccurrences.map { $0.toScheduledMeetingOccurrenceEntity() }
                    
                    continuation.resume(returning: occurrences)
                })
        }
    }
}

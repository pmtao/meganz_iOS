@testable import MEGA
import MEGADomain

struct MockScheduledMeetingUseCase: ScheduledMeetingUseCaseProtocol {
    var scheduledMeetingsList: [ScheduledMeetingEntity] = []
    var scheduledMeetingsOccurrences: [ScheduledMeetingOccurrenceEntity] = []
    var recurringMeetingsNextDates: [ChatIdEntity:Date] = [:]

    func scheduledMeetings() -> [ScheduledMeetingEntity] {
        scheduledMeetingsList
    }
    
    func scheduledMeetingsByChat(chatId: ChatIdEntity) -> [ScheduledMeetingEntity] {
        scheduledMeetingsList
    }
    
    func scheduledMeeting(for scheduledMeetingId: ChatIdEntity, chatId: ChatIdEntity) -> ScheduledMeetingEntity? {
        scheduledMeetingsList.first
    }
    
    func scheduledMeetingOccurrencesByChat(chatId: ChatIdEntity) async throws -> [ScheduledMeetingOccurrenceEntity] {
        scheduledMeetingsOccurrences
    }
    
    func scheduledMeetingOccurrencesByChat(chatId: MEGADomain.ChatIdEntity, since: Date) async throws -> [MEGADomain.ScheduledMeetingOccurrenceEntity] {
        scheduledMeetingsOccurrences
    }
    
    func recurringMeetingsNextDates(_ meetings: [ScheduledMeetingEntity]) async throws -> [ChatIdEntity:Date] {
        recurringMeetingsNextDates
    }
}

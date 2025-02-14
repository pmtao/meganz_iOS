import Foundation
@testable import MEGA
import MEGADomain

final class MockChatSDK: MEGAChatSdk {
    private let chatRoom: MEGAChatRoom?
    
    init(chatRoom: MEGAChatRoom? = MockChatRoom()) {
        self.chatRoom = chatRoom
        super.init()
    }
    
    override func chatRoom(forChatId chatId: HandleEntity) -> MEGAChatRoom? {
        chatRoom
    }
}

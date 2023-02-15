import Foundation
import MEGADomain
import MEGAPresentation

enum TurnOnNotificationsViewAction: ActionType {
    case onViewLoaded
    case dismiss
    case openSettings
}

protocol TurnOnNotificationsViewRouting: Routing {
    func dismiss()
    func openSettings()
}

final class TurnOnNotificationsViewModel: ViewModelType {
    enum Command: CommandType, Equatable {
        case configView(TurnOnNotificationsModel)
    }
    
    // MARK: - Private properties
    private let router: TurnOnNotificationsViewRouting
    
    @PreferenceWrapper(key: .lastDateTurnOnNotificationsShowed, defaultValue: Date.init(timeIntervalSince1970: 0))
    private var lastDateTurnOnNotificationsShowedPreference: Date
    
    @PreferenceWrapper(key: .timesTurnOnNotificationsShowed, defaultValue: 0)
    private var timesTurnOnNotificationsShowedPreference: Int
    
    private let authUseCase: AuthUseCaseProtocol
        
    var invokeCommand: ((Command) -> Void)?
    
    // MARK: - Init
    init(router: TurnOnNotificationsViewRouting,
         preferenceUseCase: PreferenceUseCaseProtocol = PreferenceUseCase.default,
         authUseCase: AuthUseCaseProtocol) {
        self.router = router
        self.authUseCase = authUseCase
        $lastDateTurnOnNotificationsShowedPreference.useCase = preferenceUseCase
        $timesTurnOnNotificationsShowedPreference.useCase = preferenceUseCase
    }
    
    func shouldShowTurnOnNotifications() -> Bool {
        guard let days = Calendar.current.dateComponents([.day], from: lastDateTurnOnNotificationsShowedPreference, to: Date()).day else {
            return false
        }
        if timesTurnOnNotificationsShowedPreference < 3 && days > 7
            && authUseCase.isLoggedIn() {
            return true
        }
        return false
    }
    
    // MARK: - Dispatch action
    func dispatch(_ action: TurnOnNotificationsViewAction) {
        switch action {
        case .onViewLoaded:
            lastDateTurnOnNotificationsShowedPreference = Date()
            timesTurnOnNotificationsShowedPreference += 1
            
            let title = Strings.Localizable.Dialog.TurnOnNotifications.Label.title
            let description = Strings.Localizable.Dialog.TurnOnNotifications.Label.description
            let stepOne = Strings.Localizable.Dialog.TurnOnNotifications.Label.stepOne
            let stepTwo = Strings.Localizable.Dialog.TurnOnNotifications.Label.stepTwo
            let stepThree = Strings.Localizable.Dialog.TurnOnNotifications.Label.stepThree
            
            let notificationsModel = TurnOnNotificationsModel(headerImageName: Asset.Images.Chat.groupChat.name,
                                                              title: title,
                                                              description: description,
                                                              stepOneImageName: Asset.Images.WarningTurnonNotifications.openSettings.name,
                                                              stepOne: stepOne,
                                                              stepTwoImageName: Asset.Images.WarningTurnonNotifications.tapNotifications.name,
                                                              stepTwo: stepTwo,
                                                              stepThreeImageName: Asset.Images.WarningTurnonNotifications.allowNotifications.name,
                                                              stepThree: stepThree,
                                                              openSettingsTitle: Strings.Localizable.Dialog.TurnOnNotifications.Button.primary,
                                                              dismissTitle: Strings.Localizable.dismiss)
            invokeCommand?(.configView(notificationsModel))
        case .dismiss:
            router.dismiss()
        case .openSettings:
            router.openSettings()
        }
    }
}

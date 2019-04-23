//
//  NotificationSettingViewModel.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class NotificationSettingViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
        let notificationSettingUseCase: NotificationSettingUseCase
    }
    
    struct Input {
        let viewWillAppear: Driver<Void>
        let didChangeSetting: Driver<Bool>
        let didChangeChatSetting: Driver<Bool>
        let didChangeBookingRemindSetting: Driver<Bool>
    }
    
    struct Output {
        let isNeedReAuthorization: Driver<Bool>
        let setting: Driver<NotificationSettingState>
        let eachSettings: Driver<[NotificationSetting]>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    private let notificationSettingUseCase: NotificationSettingUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
        notificationSettingUseCase = dependency.notificationSettingUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        let notificationSettingUseCase = self.notificationSettingUseCase
        
        let meAction = Driver.just(())
            .flatMap { _ -> Driver<Action<User>> in
                let source = userUseCase.me()
                return Action.makeDriver(source)
            }
        
        let updateSettingAction = input.didChangeSetting
            .withLatestFrom(meAction.elements) { ($0, $1 )}
            .flatMap { isOn, user -> Driver<Action<NotificationSettingState>> in
                let source = notificationSettingUseCase.update(userID: user.toUserID, isNotificationOn: isOn)
                return Action.makeDriver(source)
            }
        
        let updateChatSettingAction = input.didChangeChatSetting
            .withLatestFrom(meAction.elements) { ($0, $1 )}
            .flatMap { isOn, user -> Driver<Action<NotificationSetting>> in
                let source = notificationSettingUseCase.updateEach(
                    userID: user.toUserID,
                    setting: NotificationSetting(topic: .chat, isOn: isOn))
                return Action.makeDriver(source)
            }
        
        let updateBookingRemindSettingAction = input.didChangeBookingRemindSetting
            .withLatestFrom(meAction.elements) { ($0, $1 )}
            .flatMap { isOn, user -> Driver<Action<NotificationSetting>> in
                let source = notificationSettingUseCase.updateEach(
                    userID: user.toUserID,
                    setting: NotificationSetting(topic: .bookingRemind, isOn: isOn))
                return Action.makeDriver(source)
            }
        
        let getSettingAction = meAction.elements
            .flatMap { user -> Driver<Action<NotificationSettingState>> in
                let source = notificationSettingUseCase.syncSetting(userID: user.toUserID)
                return Action.makeDriver(source)
            }
        
        let getEachSettingAction = getSettingAction.elements
            .withLatestFrom(meAction.elements)
            .flatMap { user -> Driver<Action<[NotificationSetting]>> in
                let source = notificationSettingUseCase.syncEachSettings(userID: user.toUserID)
                return Action.makeDriver(source)
            }
        
        let isNeedReAuthotizationAction = Driver.merge(input.viewWillAppear, updateSettingAction.elements.mapToVoid())
            .withLatestFrom(meAction.elements)
            .flatMap { user -> Driver<Action<Bool>> in
                let source = notificationSettingUseCase.isNeedReAuth(userID: user.toUserID)
                return Action.makeDriver(source)
            }
        
        let setting = Driver.merge(getSettingAction.elements, updateSettingAction.elements)
        let eachSettings = getEachSettingAction.elements
        
        let isNeedReAuthorization = isNeedReAuthotizationAction.elements
        
        let error = Driver.merge(
            meAction.error,
            getSettingAction.error,
            getEachSettingAction.error,
            updateSettingAction.error,
            updateChatSettingAction.error,
            updateBookingRemindSettingAction.error,
            isNeedReAuthotizationAction.error
        )
        
        return Output(
            isNeedReAuthorization: isNeedReAuthorization,
            setting: setting,
            eachSettings: eachSettings,
            error: error)
    }
}

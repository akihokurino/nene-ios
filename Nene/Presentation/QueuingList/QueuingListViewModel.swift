//
//  QueuingListViewModel.swift
//  Nene
//
//  Created by akiho on 2019/02/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UserNotifications
import FirebaseInstanceID

final class QueuingListViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
        let queuingUseCase: QueuingUseCase
        let notificationSettingUseCase: NotificationSettingUseCase
    }
    
    struct Input {
        let willEnterForeground: Driver<Void>
        let viewWillAppear: Driver<Void>
        let didTapNotificationButton: Driver<Void>
    }
    
    struct Output {
        let me: Driver<User>
        let currentLine: Driver<Int>
        let isExecuting: Driver<Bool>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    private let queuingUseCase: QueuingUseCase
    private let notificationSettingUseCase: NotificationSettingUseCase
    
    init(dependency: Dependency) {
        queuingUseCase = dependency.queuingUseCase
        userUseCase = dependency.userUseCase
        notificationSettingUseCase = dependency.notificationSettingUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        let queuingUseCase = self.queuingUseCase
        let notificationSettingUseCase = self.notificationSettingUseCase
        
        let meAction = Driver.merge(Driver.just(()), input.viewWillAppear, input.willEnterForeground)
            .flatMap { _ -> Driver<Action<User>> in
                let source = userUseCase.meWithoutCache()
                return Action.makeDriver(source)
            }
        
        let getCurrentLineAction = meAction.elements
            .flatMap { user -> Driver<Action<Int>> in
                let source = queuingUseCase.currentLine(userID: user.toUserID)
                return Action.makeDriver(source)
            }
        
        let authorizeNotificationAction = input.didTapNotificationButton
            .withLatestFrom(meAction.elements)
            .flatMap { user -> Driver<Action<Void>> in
                let source = notificationSettingUseCase.requestAuthorization(userID: user.toUserID)
                return Action.makeDriver(source)
            }
        
        let me = meAction.elements
        
        let currentLine = getCurrentLineAction.elements
        
        let isExecuting = Driver.merge(getCurrentLineAction.isExecuting, authorizeNotificationAction.isExecuting)
        
        let error = Driver.merge(
            meAction.error,
            getCurrentLineAction.error,
            authorizeNotificationAction.error)
        
        return Output(
            me: me,
            currentLine: currentLine,
            isExecuting: isExecuting,
            error: error
        )
    }
}

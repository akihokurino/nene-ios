//
//  TabBarViewModel.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UserNotifications
import FirebaseInstanceID

final class TabBarViewModel: InjectableViewModel {

    struct Dependency {
        let userUseCase: UserUseCase
        let notificationSettingUseCase: NotificationSettingUseCase
    }
    
    struct Input {
        let viewWillAppear: Driver<Void>
    }
    
    struct Output {
        let updatedFCMToken: Driver<Void>
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
        
        let updatedFCMToken = NotificationCenter.default.rx.notification(.InstanceIDTokenRefresh)
            .asDriver(onErrorDriveWith: .empty())
            .map { _ in InstanceID.instanceID().token() }
            .startWith(InstanceID.instanceID().token())
            .flatMap(Driver.from(optional:))
            .flatMap { token -> Driver<Action<Void>> in
                if let userID = userUseCase.loginUserID() {
                    let source = notificationSettingUseCase.updateFCMToken(userID: userID, token: token)
                    return Action.makeDriver(source)
                }
                
                return Driver.empty()
            }
            .mapToVoid()
        
        return Output(updatedFCMToken: updatedFCMToken)
    }
}

//
//  SettingViewModel.swift
//  Neon
//
//  Created by akiho on 2019/01/11.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
    }
    
    struct Input {
        let didTapLogoutButton: Driver<Void>
    }
    
    struct Output {
        let didLogout: Driver<Void>
        let isExecuting: Driver<Bool>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        
        let logoutAction = input.didTapLogoutButton
            .flatMap { _ -> Driver<Action<Void>> in
                let source = userUseCase.logout()
                return Action.makeDriver(source)
            }
        
        let didLogout = logoutAction.elements
        let isExecuting = logoutAction.isExecuting
        let error = Driver.merge(logoutAction.error)
        
        return Output(
            didLogout: didLogout,
            isExecuting: isExecuting,
            error: error)
    }
}

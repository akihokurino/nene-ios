//
//  PinCodeViewModel.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PinCodeViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
    }
    
    struct Input {
        let didInputPinCode: Driver<String>
    }
    
    struct Output {
        let login: Driver<User>
        let isExecuting: Driver<Bool>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        
        let loginAction = input.didInputPinCode
            .filter { $0.count == 6 }
            .flatMap { pinCode -> Driver<Action<User>> in
                let source = userUseCase.loginWithPinCode(pinCode: pinCode, now: Date())
                return Action.makeDriver(source)
            }
        
        let login = loginAction.elements
        let isExecuting = Driver.merge(loginAction.isExecuting)
        let error = Driver.merge(loginAction.error)
        
        return Output(login: login,
                      isExecuting: isExecuting,
                      error: error)
    }
}

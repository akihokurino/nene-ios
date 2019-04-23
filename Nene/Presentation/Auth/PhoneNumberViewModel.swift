//
//  PhoneNumberViewModel.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PhoneNumberViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
    }
    
    struct Input {
        let phoneNumber: Driver<String>
        let didTapSendSMSButton: Driver<Void>
    }
    
    struct Output {
        let sendSMS: Driver<Void>
        let isExecuting: Driver<Bool>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        
        let sendSMSAction = input.didTapSendSMSButton
            .withLatestFrom(input.phoneNumber)
            .flatMap { number -> Driver<Action<Void>> in
                let source = userUseCase.requestPinCode(phoneNumber: PhoneNumber(value: number))
                return Action.makeDriver(source)
            }
        
        let sendSMS = sendSMSAction.elements
        let isExecuting = sendSMSAction.isExecuting
        let error = Driver.merge(sendSMSAction.error)
        
        return Output(sendSMS: sendSMS, isExecuting: isExecuting, error: error)
    }
}

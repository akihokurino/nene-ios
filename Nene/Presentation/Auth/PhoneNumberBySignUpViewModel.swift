//
//  PhoneNumberBySignUpViewModel.swift
//  Nene
//
//  Created by akiho on 2019/02/15.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PhoneNumberBySignUpViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
        let queuingUseCase: QueuingUseCase
    }
    
    struct Input {
        let code: Driver<String>
        let phoneNumber: Driver<String>
        let didTapSendSMSButton: Driver<Void>
    }
    
    struct Output {
        let sendSMS: Driver<Void>
        let isExecuting: Driver<Bool>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    private let queuingUseCase: QueuingUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
        queuingUseCase = dependency.queuingUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        let queuingUseCase = self.queuingUseCase
        
        let sendSMSAction = input.didTapSendSMSButton
            .withLatestFrom(input.phoneNumber)
            .withLatestFrom(input.code) { ($0, $1) }
            .flatMap { number, code -> Driver<Action<Void>> in
                queuingUseCase.registerCode(code: code)
                let source = userUseCase.requestPinCode(phoneNumber: PhoneNumber(value: number))
                return Action.makeDriver(source)
            }
        
        let sendSMS = sendSMSAction.elements
        let isExecuting = sendSMSAction.isExecuting
        let error = Driver.merge(sendSMSAction.error)
        
        return Output(sendSMS: sendSMS, isExecuting: isExecuting, error: error)
    }
}

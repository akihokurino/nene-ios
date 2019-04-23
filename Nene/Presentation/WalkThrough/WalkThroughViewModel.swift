//
//  WalkThroughViewModel.swift
//  Nene
//
//  Created by akiho on 2019/03/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyUserDefaults

final class WalkThroughViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
    }
    
    struct Input {
        let didTapStartButton: Driver<Void>
    }
    
    struct Output {
        let startWithMe: Driver<User?>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        
        let startAction = input.didTapStartButton
            .do(onNext: {
                Defaults[.isAlreadyShownWalkThrough] = true
            })
            .flatMap { _ -> Driver<Action<User?>> in
                let source = userUseCase.me()
                    .map { Optional($0) }
                    .catchError { error -> Single<User?> in
                        if AppError.isNotLoginError(error) {
                            return Single.just(nil)
                        } else if AppError.isNotExistError(error) {
                            return userUseCase.logout().map { nil }
                        } else {
                            return Single.error(error)
                        }
                }
                return Action.makeDriver(source)
            }
        
        let startWithMe = startAction.elements
        let error = startAction.error
        
        return Output(startWithMe: startWithMe, error: error)
    }
}

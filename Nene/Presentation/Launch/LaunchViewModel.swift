//
//  LaunchViewModel.swift
//  Nene
//
//  Created by akiho on 2019/02/14.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyUserDefaults

final class LaunchViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
    }
    
    struct Input {
        
    }
    
    struct Output {
        let meWithNeedWalkThrough: Driver<(User?, Bool)>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        
        let meAction = Driver.just(())
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
        
        let meWithNeedWalkThrough = meAction.elements.map { ($0, Defaults[.isAlreadyShownWalkThrough]) }
        let error = meAction.error
        
        return Output(meWithNeedWalkThrough: meWithNeedWalkThrough, error: error)
    }
}

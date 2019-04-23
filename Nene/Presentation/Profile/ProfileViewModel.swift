//
//  ProfileViewModel.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
    }
    
    struct Input {
        let viewWillAppear: Driver<Void>
        let didInputLastName: Driver<String>
        let didInputFirstName: Driver<String>
        let didInputLastNameKana: Driver<String>
        let didInputFirstNameKana: Driver<String>
        let didInputAreaField: Driver<String>
        let didInputDislikeFoodField: Driver<String>
        let didSelectPreferenceSeatType: Driver<User.PreferenceSeatType>
        let didSelectPreferenceGenres: Driver<[User.PreferenceGenre]>
        let didInputOther: Driver<String>
        let didTapSaveButton: Driver<Void>
    }
    
    struct Output {
        let user: Driver<User>
        let isExecuting: Driver<Bool>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        
        let inputUser = Driver.combineLatest(
            input.didInputLastName,
            input.didInputFirstName,
            input.didInputLastNameKana,
            input.didInputFirstNameKana,
            input.didInputAreaField,
            input.didInputDislikeFoodField,
            input.didSelectPreferenceSeatType,
            input.didInputOther
        ) { lastName, firstName, lastNameKana, firstNameKana, area, dislikeFood, seatType, other -> UserParams in
            return UserParams(
                lastName: lastName,
                firstName: firstName,
                lastNameKana: lastNameKana,
                firstNameKana: firstNameKana,
                iconURL: nil,
                area: area,
                dislikeFood: dislikeFood,
                preferenceSeatType: seatType,
                preferenceGenres: [],
                other: other
            )
        }
        
        let meAction = input.viewWillAppear
            .flatMap { _ -> Driver<Action<User>> in
                let source = userUseCase.me()
                return Action.makeDriver(source)
            }
        
        let updateUserAction = input.didTapSaveButton
            .withLatestFrom(inputUser)
            .withLatestFrom(input.didSelectPreferenceGenres) { params, genres -> UserParams in
                return params.updateGenres(genres: genres)
            }
            .flatMap { params -> Driver<Action<User>> in
                let source = userUseCase.update(params: params, now: Date())
                return Action.makeDriver(source)
            }
        
        let user = Driver.merge(meAction.elements, updateUserAction.elements)
        let isExecuting = Driver.merge(meAction.isExecuting, updateUserAction.isExecuting)
        let error = Driver.merge(meAction.error, updateUserAction.error)
        
        return Output(user: user,
                      isExecuting: isExecuting,
                      error: error)
    }
}

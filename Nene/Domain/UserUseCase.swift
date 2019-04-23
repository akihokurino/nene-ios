//
//  UserUseCase.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import SwiftyUserDefaults

protocol UserUseCase {
    func requestPinCode(phoneNumber: PhoneNumber) -> Single<Void>
    func requestPinCodeAgain() -> Single<Void>
    func loginWithPinCode(pinCode: String, now: Date) -> Single<User>
    func logout() -> Single<Void>
    func loginUserID() -> UserID?
    func me() -> Single<User>
    func meWithoutCache() -> Single<User>
    func update(params: UserParams, now: Date) -> Single<User>
}

struct UserParams {
    let lastName: String
    let firstName: String
    let lastNameKana: String
    let firstNameKana: String
    let iconURL: URL?
    let area: String
    let dislikeFood: String
    let preferenceSeatType: User.PreferenceSeatType
    let preferenceGenres: [User.PreferenceGenre]
    let other: String
    
    func updateGenres(genres: [User.PreferenceGenre]) -> UserParams {
        return UserParams(lastName: lastName,
                          firstName: firstName,
                          lastNameKana: lastNameKana,
                          firstNameKana: firstNameKana,
                          iconURL: iconURL,
                          area: area,
                          dislikeFood: dislikeFood,
                          preferenceSeatType: preferenceSeatType,
                          preferenceGenres: genres,
                          other: other)
    }
}

final class UserUseCaseImpl: UserUseCase {
    private let transaction: Transaction
    private let userRepository: UserRepository
    private let notificationSettingRepository: NotificationSettingRepository
    private let customerRepository: CustomerRepository
    private let queuingRepository: QueuingRepository
    
    private var user: User?
    private var usePhoneNumber: PhoneNumber?
    
    init(transaction: Transaction,
         userRepository: UserRepository,
         notificationSettingRepository: NotificationSettingRepository,
         customerRepository: CustomerRepository,
         queuingRepository: QueuingRepository) {
        self.transaction = transaction
        self.userRepository = userRepository
        self.notificationSettingRepository = notificationSettingRepository
        self.customerRepository = customerRepository
        self.queuingRepository = queuingRepository
    }
    
    func requestPinCode(phoneNumber: PhoneNumber) -> Single<Void> {
        return userRepository.requestPinCode(phoneNumber: phoneNumber)
            .do(onSuccess: { [weak self] in
                Defaults[.verificationID] = $0
                self?.usePhoneNumber = phoneNumber
            })
            .map { _ in }
    }
    
    func requestPinCodeAgain() -> Single<Void> {
        guard let phoneNumber = usePhoneNumber else {
            return Single.error(AppError.toInternalError())
        }
        
        return userRepository.requestPinCode(phoneNumber: phoneNumber)
            .do(onSuccess: { [weak self] in
                Defaults[.verificationID] = $0
                self?.usePhoneNumber = phoneNumber
            })
            .map { _ in }
    }
    
    func loginWithPinCode(pinCode: String, now: Date) -> Single<User> {
        let userRepository = self.userRepository
        let _self = self
        
        return userRepository.loginWithPinCode(pinCode: pinCode, verificationID: Defaults[.verificationID])
            .flatMap { userID -> Single<User> in
                return userRepository.getProfile(userID: userID)
                    .catchError({ error -> Single<User> in
                        if AppError.isNotExistError(error) {
                            return _self.initUser(userID: userID, now: now)
                        }
                        
                        return Single.error(error)
                    })
            }
            .do(onSuccess: { [weak self] user in
                self?.user = user
                Defaults[.verificationID] = ""
                self?.usePhoneNumber = nil
            })
    }
    
    func logout() -> Single<Void> {
        return userRepository.logout()
            .do(onSuccess: {
                self.user = nil
            })
    }
    
    private func initUser(userID: UserID, now: Date) -> Single<User> {
        let notificationSettingRepository = self.notificationSettingRepository
        let customerRepository = self.customerRepository
        let userRepository = self.userRepository
        let queuingRepository = self.queuingRepository
        
        let newUser = User.initUser(id: userID.id, now: now)
        
        return transaction.batch(executions: [
            { batch in
                userRepository.create(batch, user: newUser)
            },
            { batch in
                notificationSettingRepository.update(
                    batch,
                    userID: newUser.toUserID,
                    setting: NotificationSetting(topic: .chat, isOn: false))
            },
            { batch in
                notificationSettingRepository.update(
                    batch,
                    userID: newUser.toUserID,
                    setting: NotificationSetting(topic: .bookingRemind, isOn: false))
            },
            { batch in
                let queuing = Queuing(userID: newUser.toUserID, code: Defaults[.registerCode], createdAt: now)
                queuingRepository.create(batch, queuing: queuing)
            }])
            .flatMap {
                return customerRepository.create().catchErrorJustReturn(())
            }
            .map { newUser.bindPhoneNumber(phoneNumber: userRepository.getPhoneNumber()) }
    }
    
    func loginUserID() -> UserID? {
        return userRepository.getLoginUserID()
    }
    
    func me() -> Single<User> {
        if let user = self.user {
            return Single.just(user)
        }
        
        return meWithoutCache()
    }
    
    func meWithoutCache() -> Single<User> {
        let userRepository = self.userRepository
        
        guard let loginID = userRepository.getLoginUserID() else {
            return Single.error(AppError.toNotLoginError())
        }
        
        return Single.just(loginID)
            .flatMap { userID -> Single<User> in
                return userRepository.getProfile(userID: userID)
                    .map { $0.bindPhoneNumber(phoneNumber: userRepository.getPhoneNumber()) }
            }
            .do(onSuccess: { [weak self] user in
                self?.user = user
            })
    }
    
    func update(params: UserParams,
                now: Date) -> Single<User> {
        let userRepository = self.userRepository
        
        guard let user = self.user else {
            return Single.error(AppError.toNotLoginError())
        }
        
        let newUser = user.update(
            lastName: params.lastName,
            firstName: params.firstName,
            lastNameKana: params.lastNameKana,
            firstNameKana: params.firstNameKana,
            iconURL: params.iconURL,
            area: params.area,
            dislikeFood: params.dislikeFood,
            preferenceSeatType: params.preferenceSeatType,
            preferenceGenres: params.preferenceGenres,
            other: params.other,
            now: now)
        
        return transaction.batch(executions: [
            { batch in
                userRepository.update(batch, user: newUser)
            }])
            .map { newUser }
            .do(onSuccess: { [weak self] user in
                self?.user = user
            })
    }
}

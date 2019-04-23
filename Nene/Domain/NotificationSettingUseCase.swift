//
//  NotificationSettingUseCase.swift
//  Nene
//
//  Created by akiho on 2019/01/15.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol NotificationSettingUseCase {
    func syncSetting(userID: UserID) -> Single<NotificationSettingState>
    func syncEachSettings(userID: UserID) -> Observable<[NotificationSetting]>
    func update(userID: UserID, isNotificationOn: Bool) -> Single<NotificationSettingState>
    func updateEach(userID: UserID, setting: NotificationSetting) -> Single<NotificationSetting>
    func updateFCMToken(userID: UserID, token: String) -> Single<Void>
    func requestAuthorization(userID: UserID) -> Single<Void>
    func isNeedReAuth(userID: UserID) -> Single<Bool>
}

final class NotificationSettingUseCaseImpl: NotificationSettingUseCase {
    private let transaction: Transaction
    private let notificationSettingRepository: NotificationSettingRepository
    private let userRepository: UserRepository
    private let notificationAuthorization: NotificationAuthorization
    
    private var notificationSettingState: NotificationSettingState?
    
    init(transaction: Transaction,
         notificationSettingRepository: NotificationSettingRepository,
         userRepository: UserRepository,
         notificationAuthorization: NotificationAuthorization) {
        self.transaction = transaction
        self.notificationSettingRepository = notificationSettingRepository
        self.userRepository = userRepository
        self.notificationAuthorization = notificationAuthorization
    }
    
    func syncSetting(userID: UserID) -> Single<NotificationSettingState> {
        if let state = notificationSettingState {
            return Single.just(state)
        }
        
        return userRepository.getNotificationSettingState(userID: userID)
            .do(onSuccess: { [weak self] state in
                self?.notificationSettingState = state
            })
    }
    
    func syncEachSettings(userID: UserID) -> Observable<[NotificationSetting]> {
        return notificationSettingRepository.observe(userID: userID)
    }
    
    func update(userID: UserID, isNotificationOn: Bool) -> Single<NotificationSettingState> {
        let userRepository = self.userRepository
        
        return transaction.batch(executions: [
            { batch in
                userRepository.update(batch, userID: userID, isNotificationOn: isNotificationOn)
            }
            ])
            .map { NotificationSettingState(isOn: isNotificationOn) }
            .do(onSuccess: { [weak self] state in
                self?.notificationSettingState = state
            })
    }
    
    func updateEach(userID: UserID, setting: NotificationSetting) -> Single<NotificationSetting> {
        let notificationSettingRepository = self.notificationSettingRepository
        
        return transaction.batch(executions: [
            { batch in
                notificationSettingRepository.update(batch, userID: userID, setting: setting)
            }
            ])
            .map { setting }
    }
    
    func updateFCMToken(userID: UserID, token: String) -> Single<Void> {
        let userRepository = self.userRepository
        
        return transaction.batch(executions: [
            { batch in
                userRepository.update(batch, userID: userID, fcmToken: token)
            }
            ])
    }
    
    func requestAuthorization(userID: UserID) -> Single<Void> {
        let transaction = self.transaction
        let authorization = self.notificationAuthorization
        let userRepository = self.userRepository
        let notificationSettingRepository = self.notificationSettingRepository
        
        return authorization.request()
            .flatMap { granted -> Single<Void> in
                return transaction.batch(executions: [
                    { batch in
                        userRepository.update(batch, userID: userID, isNotificationOn: granted)
                    },
                    { batch in
                        let setting = NotificationSetting(topic: .chat, isOn: granted)
                        notificationSettingRepository.update(batch, userID: userID, setting: setting)
                    },
                    {  batch in
                        let setting = NotificationSetting(topic: .bookingRemind, isOn: granted)
                        notificationSettingRepository.update(batch, userID: userID, setting: setting)
                    }
                    ])
                    .map { _ in NotificationSettingState(isOn: granted) }
                    .do(onSuccess: { [weak self] state in
                        self?.notificationSettingState = state
                    })
                    .map { _ in }
            }
    }
    
    func isNeedReAuth(userID: UserID) -> Single<Bool> {
        let authorization = self.notificationAuthorization
    
        return syncSetting(userID: userID)
            .flatMap { state -> Single<Bool> in
                if !state.isOn {
                    return Single.just(false)
                }
                
                return authorization.getSettings().map { $0.authorizationStatus == .denied }
            }
    }
}

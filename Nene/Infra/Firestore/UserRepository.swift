//
//  UserRepository.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class UserRepositoryImpl: UserRepository {
    private let db: Firestore
    private let converter: PrimitiveConverter
    
    init(db: Firestore, converter: PrimitiveConverter) {
        self.db = db
        self.converter = converter
    }
    
    func getLoginUserID() -> UserID? {
        if let user = Auth.auth().currentUser {
            return UserID(id: user.uid)
        }
        
        return nil
    }
    
    func getPhoneNumber() -> PhoneNumber? {
        guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber else {
            return nil
        }
        
        return PhoneNumber(value: phoneNumber)
    }
    
    func getProfile(userID: UserID) -> Single<User> {
        let db = self.db
        let converter = self.converter
        
        return Single<User>
            .create(subscribe: { observer -> Disposable in
                db.collection(UserEntity.collectionName)
                    .document(UserEntity.documentName(userID: userID))
                    .getDocument { (document, error) in
                        if let error = error {
                            observer(.error(AppError.toInternalError(error)))
                            return
                        }
                        
                        if let document = document, document.exists {
                            if let data = document.data() {
                                observer(.success(UserEntity.to(data: data, converter: converter)))
                                return
                            }
                        } else {
                            observer(.error(AppError.toNotExistError()))
                            return
                        }
                        
                        observer(.error(AppError.toInternalError()))
                    }
            
                return Disposables.create()
            })
    }
    
    func getSubscriptionState(userID: UserID) -> Single<SubscriptionState> {
        let db = self.db
        let converter = self.converter
        
        return Single<SubscriptionState>
            .create(subscribe: { observer -> Disposable in
                db.collection(UserEntity.collectionName)
                    .document(UserEntity.documentName(userID: userID))
                    .getDocument { (document, error) in
                        if let error = error {
                            observer(.error(AppError.toInternalError(error)))
                            return
                        }
                        
                        if let document = document, document.exists {
                            if let data = document.data() {
                                observer(.success(UserEntity.toSubscriptionState(data: data, converter: converter)))
                                return
                            }
                        } else {
                            observer(.error(AppError.toNotExistError()))
                            return
                        }
                        
                        observer(.error(AppError.toInternalError()))
                    }
                
                return Disposables.create()
            })
    }
    
    func getMessageState(userID: UserID) -> Single<MessageState> {
        let db = self.db
        let converter = self.converter
        
        return Single<MessageState>
            .create(subscribe: { observer -> Disposable in
                db.collection(UserEntity.collectionName)
                    .document(UserEntity.documentName(userID: userID))
                    .getDocument { (document, error) in
                        if let error = error {
                            observer(.error(AppError.toInternalError(error)))
                            return
                        }
                        
                        if let document = document, document.exists {
                            if let data = document.data() {
                                observer(.success(UserEntity.toMessageState(data: data, converter: converter)))
                                return
                            }
                        } else {
                            observer(.error(AppError.toNotExistError()))
                            return
                        }
                        
                        observer(.error(AppError.toInternalError()))
                    }
                
                return Disposables.create()
            })
    }
    
    func getNotificationSettingState(userID: UserID) -> Single<NotificationSettingState> {
        let db = self.db
        let converter = self.converter
        
        return Single<NotificationSettingState>
            .create(subscribe: { observer -> Disposable in
                db.collection(UserEntity.collectionName)
                    .document(UserEntity.documentName(userID: userID))
                    .getDocument { (document, error) in
                        if let error = error {
                            observer(.error(AppError.toInternalError(error)))
                            return
                        }
                        
                        if let document = document, document.exists {
                            if let data = document.data() {
                                observer(.success(UserEntity.toNotificationSettingState(data: data, converter: converter)))
                                return
                            }
                        } else {
                            observer(.error(AppError.toNotExistError()))
                            return
                        }
                        
                        observer(.error(AppError.toInternalError()))
                }
                
                return Disposables.create()
            })
    }
    
    func requestPinCode(phoneNumber: PhoneNumber) -> Single<String> {
        return Single<String>
            .create(subscribe: { (observer) -> Disposable in
                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.toE164(), uiDelegate: nil) { (verificationID, error) in
                    if let error = error {
                        observer(.error(AppError.toInternalError(error)))
                        return
                    }
                    
                    observer(.success((verificationID ?? "")))
                }
                
                return Disposables.create()
            })
    }
    
    func loginWithPinCode(pinCode: String, verificationID: String) -> Single<UserID> {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: pinCode)
        
        return Single<UserID>
            .create(subscribe: { (observer) -> Disposable in
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    if let error = error {
                        if let code = AuthErrorCode(rawValue: error._code) {
                            switch code {
                            case .invalidVerificationCode, .invalidVerificationID:
                                observer(.error(AppError.toInvalidPinCode()))
                                return
                            default:
                                break
                            }
                        }
                        
                        observer(.error(AppError.toInternalError(error)))
                        return
                    }
                    
                    guard let user = authResult?.user else {
                        observer(.error(AppError.toInternalError()))
                        return
                    }
                    
                    observer(.success(UserID(id: user.uid)))
                }
                
                return Disposables.create()
            })
    }
    
    func logout() -> Single<Void> {
        return Single<Void>
            .create(subscribe: { (observer) -> Disposable in
                do {
                    try Auth.auth().signOut()
                    observer(.success(()))
                } catch let error as NSError {
                    observer(.error(error))
                }
                
                return Disposables.create()
            })
    }
    
    func create(_ batch: WriteBatch, user: User) {
        let entity = UserEntity.from(user: user)
        
        let ref = db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: user.toUserID))
        
        batch.setData(entity.doc(), forDocument: ref)
    }
    
    func update(_ batch: WriteBatch, user: User) {
        let entity = UserEntity.from(user: user)
        
        let ref = db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: user.toUserID))
        
        batch.setData(entity.doc(), forDocument: ref, merge: true)
    }
    
    func update(_ batch: WriteBatch, userID: UserID, isNotificationOn: Bool) {
        let ref = db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: userID))
        
        batch.setData(["enablePushNotification": isNotificationOn], forDocument: ref, merge: true)
    }
    
    func update(_ batch: WriteBatch, userID: UserID, fcmToken: String) {
        let ref = db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: userID))
        
        batch.setData(["fcmToken": fcmToken], forDocument: ref, merge: true)
    }
    
    func update(_ batch: WriteBatch, userID: UserID, isAlreadyMessage: Bool) {
        let ref = db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: userID))
        
        batch.setData(["isAlreadyMessage": isAlreadyMessage], forDocument: ref, merge: true)
    }
    
    func update(_ batch: WriteBatch, userID: UserID, isReceivedStartMessage: Bool) {
        let ref = db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: userID))
        
        batch.setData(["isReceivedStartMessage": isReceivedStartMessage], forDocument: ref, merge: true)
    }
    
    func update(_ batch: WriteBatch, userID: UserID, messageAt: Date) {
        let ref = db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: userID))
        
        batch.setData(["messageAt": Int(messageAt.timeIntervalSince1970)], forDocument: ref, merge: true)
    }
}

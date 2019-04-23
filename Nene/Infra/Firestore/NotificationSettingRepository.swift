//
//  NotificationSettingRepository.swift
//  Nene
//
//  Created by akiho on 2019/01/15.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class NotificationSettingRepositoryImpl: NotificationSettingRepository {
    private let db: Firestore
    private let converter: PrimitiveConverter
    
    init(db: Firestore, converter: PrimitiveConverter) {
        self.db = db
        self.converter = converter
    }
    
    func observe(userID: UserID) -> Observable<[NotificationSetting]> {
        let db = self.db
        let converter = self.converter
        let subject = PublishSubject<[NotificationSetting]>()
        
        db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: userID))
            .collection(NotificationSettingEntity.collectionName)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    subject.onError(AppError.toInternalError(error))
                    return
                }
                
                guard let document = documentSnapshot else {
                    subject.onError(AppError.toInternalError())
                    return
                }
                
                let bookings = document.documents.map { snapshot -> NotificationSetting in
                    return NotificationSettingEntity.to(data: snapshot.data(), converter: converter)
                }
                
                subject.onNext(bookings)
            }
        
        return subject.asObservable()
    }
    
    func update(_ batch: WriteBatch, userID: UserID, setting: NotificationSetting) {
        let ref = db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: userID))
            .collection(NotificationSettingEntity.collectionName)
            .document(NotificationSettingEntity.documentName(topic: setting.topic))
        
        let entity = NotificationSettingEntity.from(setting: setting)
        
        batch.setData(entity.doc(), forDocument: ref, merge: true)
    }
}

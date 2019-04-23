//
//  QueuingRepository.swift
//  Nene
//
//  Created by akiho on 2019/02/14.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class QueuingRepositoryImpl: QueuingRepository {
    private let db: Firestore
    private let converter: PrimitiveConverter
    
    init(db: Firestore, converter: PrimitiveConverter) {
        self.db = db
        self.converter = converter
    }
    
    func get(userID: UserID) -> Single<Queuing> {
        let db = self.db
        let converter = self.converter
        
        return Single<Queuing>
            .create(subscribe: { observer -> Disposable in
                db.collection(QueuingEntity.collectionName)
                    .document(QueuingEntity.documentName(userID: userID))
                    .getDocument { (document, error) in
                        if let error = error {
                            observer(.error(AppError.toInternalError(error)))
                            return
                        }
                        
                        if let document = document, document.exists {
                            if let data = document.data() {
                                observer(.success(QueuingEntity.to(data: data, converter: converter)))
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
    
    func getCountByOlder(at: Date) -> Single<Int> {
        let db = self.db
        
        return Single<Int>
            .create(subscribe: { observer -> Disposable in
                db.collection(QueuingEntity.collectionName)
                    .whereField("createdAt", isLessThan: at.timeIntervalSince1970)
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            observer(.error(AppError.toInternalError(error)))
                            return
                        }
                        
                        observer(.success(querySnapshot!.documents.count))
                    }
                
                return Disposables.create()
            })
    }
    
    func create(_ batch: WriteBatch, queuing: Queuing) {
        let ref = db.collection(QueuingEntity.collectionName)
            .document(QueuingEntity.documentName(userID: queuing.userID))
        
        let entity = QueuingEntity.from(queuing: queuing)
        
        batch.setData(entity.doc(), forDocument: ref)
    }
}

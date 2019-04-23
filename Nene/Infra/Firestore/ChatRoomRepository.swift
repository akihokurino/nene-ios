//
//  ChatRoomRepository.swift
//  Neon
//
//  Created by akiho on 2019/01/06.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class ChatRoomRepositoryImpl: ChatRoomRepository {
    private let db: Firestore
    private let converter: PrimitiveConverter
    
    init(db: Firestore, converter: PrimitiveConverter) {
        self.db = db
        self.converter = converter
    }
    
    func get(userID: UserID) -> Single<ChatRoom> {
        let db = self.db
        let converter = self.converter
        
        return Single<ChatRoom>
            .create(subscribe: { observer -> Disposable in
                db.collection(ChatRoomEntity.collectionName)
                    .document(ChatRoomEntity.documentName(userID: userID))
                    .getDocument { (document, error) in
                        if let error = error {
                            observer(.error(AppError.toInternalError(error)))
                            return
                        }
                        
                        if let document = document, document.exists {
                            if let data = document.data() {
                                observer(.success(ChatRoomEntity.to(data: data, converter: converter)))
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
    
    func create(_ batch: WriteBatch, chatRoom: ChatRoom) {
        let ref = db.collection(ChatRoomEntity.collectionName)
            .document(ChatRoomEntity.documentName(userID: chatRoom.userID))
        
        let entity = ChatRoomEntity.from(chatRoom: chatRoom)
        
        batch.setData(entity.doc(), forDocument: ref)
    }
    
    func update(_ batch: WriteBatch, chatRoom: ChatRoom, now: Date) {
        let ref = db.collection(ChatRoomEntity.collectionName)
            .document(ChatRoomEntity.documentName(userID: chatRoom.userID))
        
        batch.setData(["updatedAt": Int(now.timeIntervalSince1970)], forDocument: ref, merge: true)
    }
}



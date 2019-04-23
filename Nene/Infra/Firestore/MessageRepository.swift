//
//  MessageRepository.swift
//  Neon
//
//  Created by akiho on 2019/01/06.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

final class MessageRepositoryImpl: MessageRepository {
    private let db: Firestore
    private let converter: PrimitiveConverter
    
    init(db: Firestore, converter: PrimitiveConverter) {
        self.db = db
        self.converter = converter
    }
    
    func observe(chatRoom: ChatRoom) -> Observable<[Message]> {
        let db = self.db
        let converter = self.converter
        let subject = PublishSubject<[Message]>()
        
        db.collection(ChatRoomEntity.collectionName)
            .document(ChatRoomEntity.documentName(userID: chatRoom.userID))
            .collection(MessageEntity.collectionName)
            .order(by: MessageEntity.orderBy, descending: true)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    subject.onError(AppError.toInternalError(error))
                    return
                }
                
                guard let document = documentSnapshot else {
                    subject.onError(AppError.toInternalError())
                    return
                }

                let messages = document.documents.map { snapshot -> Message in
                    return MessageEntity.to(data: snapshot.data(), converter: converter)
                }

                subject.onNext(messages)
            }
        
        return subject.asObservable()
    }
    
    func create(_ batch: WriteBatch, chatRoom: ChatRoom, message: Message) {
        let ref = db.collection(ChatRoomEntity.collectionName)
            .document(ChatRoomEntity.documentName(userID: chatRoom.userID))
            .collection(MessageEntity.collectionName)
            .document(MessageEntity.documentName(id: message.id))
        
        let entity = MessageEntity.from(message: message)
        
        batch.setData(entity.doc(), forDocument: ref)
    }
}

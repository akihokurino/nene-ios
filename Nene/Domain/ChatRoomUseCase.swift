//
//  ChatRoomUseCase.swift
//  Neon
//
//  Created by akiho on 2019/01/06.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

protocol ChatRoomUseCase {
    func checkEnabled(me: User, subscriptionState: SubscriptionState?, now: Date) -> Driver<Bool>
    func initRoom(userID: UserID, now: Date) -> Single<ChatRoom>
    func syncMessage(userID: UserID) -> Observable<[Message]>
    func sendMessage(userID: UserID, text: String, now: Date) -> Single<Void>
}

final class ChatRoomUseCaseImpl: ChatRoomUseCase {
    private let transaction: Transaction
    private let userRepository: UserRepository
    private let chatRoomRepository: ChatRoomRepository
    private let messageRepository: MessageRepository
    private let idGenerator: IDGenerator
    private let dynamicConfig: DynamicConfig

    private var chatRoom: ChatRoom?
    
    private let maxTextLength = 1024
    
    init(transaction: Transaction,
         userRepository: UserRepository,
         chatRoomRepository: ChatRoomRepository,
         messageRepository: MessageRepository,
         idGenerator: IDGenerator,
         dynamicConfig: DynamicConfig) {
        self.transaction = transaction
        self.userRepository = userRepository
        self.chatRoomRepository = chatRoomRepository
        self.messageRepository = messageRepository
        self.idGenerator = idGenerator
        self.dynamicConfig = dynamicConfig
    }
    
    func checkEnabled(me: User, subscriptionState: SubscriptionState?, now: Date) -> Driver<Bool> {
        if subscriptionState != nil && subscriptionState!.isSubscribe {
            return Driver.just(true)
        }
        
        guard let startedAt = me.startedAt else {
            return Driver.just(false)
        }
        
        let diff = Int(now.timeIntervalSince(startedAt))
        return dynamicConfig.freeDuration.map { diff < $0 }
    }
    
    func initRoom(userID: UserID, now: Date) -> Single<ChatRoom> {
        let transaction = self.transaction
        let chatRoomRepository = self.chatRoomRepository
        let userRepository = self.userRepository
        let idGenerator = self.idGenerator
        let messageRepository = self.messageRepository
        
        return userRepository.getMessageState(userID: userID)
            .flatMap { state -> Single<(ChatRoom, MessageState)> in
                return chatRoomRepository.get(userID: userID)
                    .catchError { error -> Single<ChatRoom> in
                        if AppError.isNotExistError(error) {
                            let chatRoom = ChatRoom.initChatRoom(id: idGenerator.generate(), userID: userID, now: now)
                            
                            return transaction.batch(executions: [
                                { batch in
                                    chatRoomRepository.create(batch, chatRoom: chatRoom)
                                }])
                                .map { _ in chatRoom }
                        }
                        
                        return Single.error(error)
                    }
                    .do(onSuccess: { [weak self] chatRoom in
                        self?.chatRoom = chatRoom
                    })
                    .map { ($0, state) }
            }
            .flatMap { pair -> Single<ChatRoom> in
                if pair.1.isReceivedStartMessage {
                    return Single.just(pair.0)
                } else {
                    return transaction.batch(executions: [
                        { batch in
                            messageRepository.create(
                                batch,
                                chatRoom: pair.0,
                                message: Message.firstSystemMessage(id: idGenerator.generate(), myID: userID, now: now))
                        },
                        {  batch in
                            userRepository.update(batch, userID: userID, isReceivedStartMessage: true)
                        }
                    ]).map { pair.0 }
                }
            }
    }
    
    func syncMessage(userID: UserID) -> Observable<[Message]> {
        let messageRepository = self.messageRepository
       
        guard let chatRoom = self.chatRoom else {
            return Observable.error(AppError.toNotLoginError())
        }
        
        return messageRepository.observe(chatRoom: chatRoom)
            .map { items -> [Message] in
                return items.map { $0.toMyMessageIfNeed(myID: userID) }
            }
    }
    
    func sendMessage(userID: UserID, text: String, now: Date) -> Single<Void> {
        let messageRepository = self.messageRepository
        let chatRoomRepository = self.chatRoomRepository
        let userRepository = self.userRepository
        let idGenerator = self.idGenerator
        
        guard text.count <= maxTextLength else {
            return Single.error(AppError.toInputError(message: "\(maxTextLength)以下で入力してください"))
        }
        
        guard let chatRoom = self.chatRoom else {
            return Single.error(AppError.toNotLoginError())
        }
        
        let message = Message(
            id: idGenerator.generate(),
            fromUserID: userID,
            toUserID: StaticConfig.adminUserID,
            text: text,
            imageURL: nil,
            createdAt: now,
            isMine: false
        )
        
        return transaction.batch(executions: [
            { batch in
                messageRepository.create(batch, chatRoom: chatRoom, message: message.toMyMessageIfNeed(myID: userID))
            },
            { batch in
                chatRoomRepository.update(batch, chatRoom: chatRoom, now: now)
            },
            { batch in
                userRepository.update(batch, userID: userID, messageAt: now)
            },
            {  batch in
                userRepository.update(batch, userID: userID, isAlreadyMessage: true)
            }
        ])
    }
}


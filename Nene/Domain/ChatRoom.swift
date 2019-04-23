//
//  ChatRoom.swift
//  Neon
//
//  Created by akiho on 2019/01/06.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

struct ChatRoom {
    let id: String
    let userID: UserID
    let adminUserID: UserID
    let assistantIDs: [UserID]
    let createdAt: Date
    let updatedAt: Date
    
    static func initChatRoom(id: String, userID: UserID, now: Date) -> ChatRoom {
        return ChatRoom(
            id: id,
            userID: userID,
            adminUserID: StaticConfig.adminUserID,
            assistantIDs: [],
            createdAt: now,
            updatedAt: now)
    }
}

protocol ChatRoomRepository {
    func get(userID: UserID) -> Single<ChatRoom>
    func create(_ batch: WriteBatch, chatRoom: ChatRoom)
    func update(_ batch: WriteBatch, chatRoom: ChatRoom, now: Date)
}

//
//  ChatRoomEntity.swift
//  Neon
//
//  Created by akiho on 2019/01/07.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct ChatRoomEntity {
    let id: String
    let userId: String
    let adminId: String
    let assistantIds: [String]
    let createdAt: Int
    let updatedAt: Int
    
    static let collectionName = "chatRooms"
    
    static func documentName(userID: UserID) -> String {
        return userID.id
    }
    
    static func from(chatRoom: ChatRoom) -> ChatRoomEntity {
        return ChatRoomEntity(
            id: chatRoom.id,
            userId: chatRoom.userID.id,
            adminId: chatRoom.adminUserID.id,
            assistantIds: [],
            createdAt: Int(chatRoom.createdAt.timeIntervalSince1970),
            updatedAt: Int(chatRoom.updatedAt.timeIntervalSince1970)
        )
    }
    
    static func to(data: [String: Any], converter: PrimitiveConverter) -> ChatRoom {
        return ChatRoom(
            id: converter.toString(data["id"]),
            userID: UserID(id: converter.toString(data["userId"])),
            adminUserID: UserID(id: converter.toString(data["adminId"])),
            assistantIDs: [],
            createdAt: Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["createdAt"]))),
            updatedAt: Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["updatedAt"])))
        )
    }
    
    func doc() -> [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "adminId": adminId,
            "assistantIds": assistantIds,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
        ]
    }
}

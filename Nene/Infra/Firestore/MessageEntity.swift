//
//  MessageEntity.swift
//  Neon
//
//  Created by akiho on 2019/01/07.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct MessageEntity {
    let id: String
    let fromUserId: String
    let toUserId: String
    let text: String
    let imageURL: String
    let createdAt: Int
    
    static let collectionName = "messages"
    
    static func documentName(id: String) -> String {
        return id
    }
    
    static let orderBy = "createdAt"
    
    static func from(message: Message) -> MessageEntity {
        return MessageEntity(
            id: message.id,
            fromUserId: message.fromUserID.id,
            toUserId: message.toUserID.id,
            text: message.text,
            imageURL: message.imageURL?.absoluteString ?? "",
            createdAt: Int(message.createdAt.timeIntervalSince1970)
        )
    }
    
    static func to(data: [String: Any], converter: PrimitiveConverter) -> Message {
        let imageURLString = converter.toString(data["imageURL"])
        return Message(
            id: converter.toString(data["id"]),
            fromUserID: UserID(id: converter.toString(data["fromUserId"])),
            toUserID: UserID(id: converter.toString(data["toUserId"])),
            text: converter.toString(data["text"]),
            imageURL: imageURLString.isEmpty ? nil : URL(string: imageURLString),
            createdAt: Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["createdAt"]))),
            isMine: false
        )
    }
    
    func doc() -> [String: Any] {
        return [
            "id": id,
            "fromUserId": fromUserId,
            "toUserId": toUserId,
            "text": text,
            "imageURL": imageURL,
            "createdAt": createdAt
        ]
    }
}

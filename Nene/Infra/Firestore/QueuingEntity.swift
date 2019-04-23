//
//  QueuingEntity.swift
//  Nene
//
//  Created by akiho on 2019/02/14.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct QueuingEntity {
    let userId: String
    let code:  String
    let createdAt: Int
    
    static let collectionName = "queuings"
    
    static func documentName(userID: UserID) -> String {
        return userID.id
    }
    
    static let orderBy = "createdAt"

    static func from(queuing: Queuing) -> QueuingEntity {
        return QueuingEntity(
            userId: queuing.userID.id,
            code: queuing.code,
            createdAt: Int(queuing.createdAt.timeIntervalSince1970))
    }
    
    static func to(data: [String: Any], converter: PrimitiveConverter) -> Queuing {
        return Queuing(
            userID:  UserID(id: converter.toString(data["userId"])),
            code: converter.toString(data["code"]),
            createdAt: Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["createdAt"])))
        )
    }
    
    func doc() -> [String: Any] {
        return [
            "userId": userId,
            "code": code,
            "createdAt": createdAt,
        ]
    }
}

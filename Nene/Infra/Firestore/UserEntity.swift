//
//  UserEntity.swift
//  Neon
//
//  Created by akiho on 2019/01/07.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct UserEntity {
    let id: String
    let lastName: String
    let firstName: String
    let lastNameKana: String
    let firstNameKana: String
    let iconURL: String
    let area: String
    let dislikeFood: String
    let preferenceSeatType: Int
    let preferenceGenres: [Int]
    let other: String
    let isWaiting: Bool
    let hasAssistant: Bool
    let startedAt: Int
    let createdAt: Int
    let updatedAt: Int
    
    static let collectionName = "users"
    
    static func documentName(userID: UserID) -> String {
        return userID.id
    }
    
    static func from(user: User) -> UserEntity {
        return UserEntity(id: user.id,
                          lastName: user.lastName,
                          firstName: user.firstName,
                          lastNameKana: user.lastNameKana,
                          firstNameKana: user.firstNameKana,
                          iconURL: user.iconURL?.absoluteString ?? "",
                          area: user.area,
                          dislikeFood: user.dislikeFood,
                          preferenceSeatType: user.preferenceSeatType.rawValue,
                          preferenceGenres: user.preferenceGenres.map { $0.rawValue },
                          other: user.other,
                          isWaiting: user.isWaiting,
                          hasAssistant: user.hasAssistant,
                          startedAt: user.startedAt != nil ? Int(user.startedAt!.timeIntervalSince1970) : 0,
                          createdAt: Int(user.createdAt.timeIntervalSince1970),
                          updatedAt: Int(user.updatedAt.timeIntervalSince1970)
        )
    }
    
    static func to(data: [String: Any], converter: PrimitiveConverter) -> User {
        let iconURLString = converter.toString(data["iconURL"])
        let startedAtTimestamp = converter.toInt(data["startedAt"])
        
        return User(
            id: converter.toString(data["id"]),
            lastName: converter.toString(data["lastName"]),
            firstName: converter.toString(data["firstName"]),
            lastNameKana: converter.toString(data["lastNameKana"]),
            firstNameKana: converter.toString(data["firstNameKana"]),
            phoneNumber: nil,
            iconURL: iconURLString.isEmpty ? nil : URL(string: iconURLString),
            area: converter.toString(data["area"]),
            dislikeFood: converter.toString(data["dislikeFood"]),
            preferenceSeatType: User.PreferenceSeatType(rawValue: converter.toInt(data["preferenceSeatType"])) ?? .unknown,
            preferenceGenres: converter.toIntArray(data["preferenceGenres"])
                .map { User.PreferenceGenre(rawValue: $0) ?? .unknown },
            other: converter.toString(data["other"]),
            isWaiting: converter.toBool(data["isWaiting"]),
            hasAssistant: converter.toBool(data["hasAssistant"]),
            startedAt: startedAtTimestamp > 0 ? Date(timeIntervalSince1970: TimeInterval(startedAtTimestamp)) : nil,
            createdAt: Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["createdAt"]))),
            updatedAt: Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["updatedAt"])))
        )
    }
    
    static func toSubscriptionState(data: [String: Any], converter: PrimitiveConverter) -> SubscriptionState {
        return SubscriptionState(
            subscriptionId: converter.toString(data["subscriptionId"]),
            cardId: converter.toString(data["cardId"]),
            customerId: converter.toString(data["customerId"])
        )
    }
    
    static func toMessageState(data: [String: Any], converter: PrimitiveConverter) -> MessageState {
        return MessageState(
            isAlreadyMessage: converter.toBool(data["isAlreadyMessage"]),
            isReceivedStartMessage: converter.toBool(data["isReceivedStartMessage"])
        )
    }
    
    static func toNotificationSettingState(data: [String: Any], converter: PrimitiveConverter) -> NotificationSettingState {
        return NotificationSettingState(
            isOn: converter.toBool(data["enablePushNotification"])
        )
    }
    
    func doc() -> [String: Any] {
        return [
            "id": id,
            "lastName": lastName,
            "firstName": firstName,
            "lastNameKana": lastNameKana,
            "firstNameKana": firstNameKana,
            "iconURL": iconURL,
            "area": area,
            "dislikeFood": dislikeFood,
            "preferenceSeatType": preferenceSeatType,
            "preferenceGenres": preferenceGenres,
            "other": other,
            "isWaiting": isWaiting,
            "hasAssistant": hasAssistant,
            "startedAt": startedAt,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
}

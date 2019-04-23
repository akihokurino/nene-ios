//
//  User.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

struct UserID {
    let id: String
}

struct SubscriptionState {
    let subscriptionId: String
    let cardId: String
    let customerId: String
    
    var isSubscribe: Bool {
        return subscriptionId != ""
    }
    
    var isRegisterCustomer: Bool {
        return customerId != ""
    }
}

struct MessageState {
    let isAlreadyMessage: Bool
    let isReceivedStartMessage: Bool
}

struct NotificationSettingState {
    let isOn: Bool
}

struct User {
    enum PreferenceSeatType: Int {
        case unknown = 0
        case table = 1
        case counter = 2
        
        var name: String {
            switch self {
            case .table:
                return "テーブル"
            case .counter:
                return "カウンター"
            default:
                return ""
            }
        }
    }
    
    enum PreferenceGenre: Int {
        case unknown = 0
        case japanese = 1
        case western = 2
        case chinese = 3
        case pot = 4
        case asia = 5
        case curry = 6
        case ramen = 7
        case tavern = 8
        case creative = 9
        case grilledMeat = 10
        
        var name: String {
            switch self {
            case .japanese:
                return "和食"
            case .western:
                return "洋食・西洋料理"
            case .chinese:
                return "中華料理"
            case .pot:
                return "鍋"
            case .asia:
                return "アジア・エスニック"
            case .curry:
                return "カレー"
            case .ramen:
                return "ラーメン"
            case .tavern:
                return "居酒屋・ダイニングバー"
            case .creative:
                return "創作料理・無国籍料理"
            case .grilledMeat:
                return "焼肉・ホルモン"
            default:
                return ""
            }
        }
    }
    
    let id: String
    let lastName: String
    let firstName: String
    let lastNameKana: String
    let firstNameKana: String
    let phoneNumber: PhoneNumber?
    let iconURL: URL?
    let area: String
    let dislikeFood: String
    let preferenceSeatType: PreferenceSeatType
    let preferenceGenres: [PreferenceGenre]
    let other: String
    let isWaiting: Bool
    let hasAssistant: Bool
    let startedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
    var toUserID: UserID {
        return UserID(id: id)
    }
    
    static func initUser(id: String, now: Date) -> User {
        return User(id: id,
                    lastName: "",
                    firstName: "",
                    lastNameKana: "",
                    firstNameKana: "",
                    phoneNumber: nil,
                    iconURL: nil,
                    area: "",
                    dislikeFood: "",
                    preferenceSeatType: .unknown,
                    preferenceGenres: [],
                    other: "",
                    isWaiting: true,
                    hasAssistant: false,
                    startedAt: nil,
                    createdAt: now,
                    updatedAt: now)
    }
    
    func update(lastName: String,
                firstName: String,
                lastNameKana: String,
                firstNameKana: String,
                iconURL: URL?,
                area: String,
                dislikeFood: String,
                preferenceSeatType: User.PreferenceSeatType,
                preferenceGenres: [User.PreferenceGenre],
                other: String,
                now: Date) -> User {
        return User(
            id: id,
            lastName: lastName,
            firstName: firstName,
            lastNameKana: lastNameKana,
            firstNameKana: firstNameKana,
            phoneNumber: phoneNumber,
            iconURL: iconURL,
            area: area,
            dislikeFood: dislikeFood,
            preferenceSeatType: preferenceSeatType,
            preferenceGenres: preferenceGenres,
            other: other,
            isWaiting: isWaiting,
            hasAssistant: hasAssistant,
            startedAt: startedAt,
            createdAt: createdAt,
            updatedAt: now)
    }
    
    func bindPhoneNumber(phoneNumber: PhoneNumber?) -> User {
        return User(
            id: id,
            lastName: lastName,
            firstName: firstName,
            lastNameKana: lastNameKana,
            firstNameKana: firstNameKana,
            phoneNumber: phoneNumber,
            iconURL: iconURL,
            area: area,
            dislikeFood: dislikeFood,
            preferenceSeatType: preferenceSeatType,
            preferenceGenres: preferenceGenres,
            other: other,
            isWaiting: isWaiting,
            hasAssistant: hasAssistant,
            startedAt: startedAt,
            createdAt: createdAt,
            updatedAt: updatedAt)
    }
}

protocol UserRepository {
    func getLoginUserID() -> UserID?
    func getPhoneNumber() -> PhoneNumber?
    func getProfile(userID: UserID) -> Single<User>
    func getSubscriptionState(userID: UserID) -> Single<SubscriptionState>
    func getMessageState(userID: UserID) -> Single<MessageState>
    func getNotificationSettingState(userID: UserID) -> Single<NotificationSettingState>
    func requestPinCode(phoneNumber: PhoneNumber) -> Single<String>
    func loginWithPinCode(pinCode: String, verificationID: String) -> Single<UserID>
    func logout() -> Single<Void>
    func create(_ batch: WriteBatch, user: User)
    func update(_ batch: WriteBatch, user: User)
    func update(_ batch: WriteBatch, userID: UserID, isNotificationOn: Bool)
    func update(_ batch: WriteBatch, userID: UserID, fcmToken: String)
    func update(_ batch: WriteBatch, userID: UserID, isAlreadyMessage: Bool)
    func update(_ batch: WriteBatch, userID: UserID, isReceivedStartMessage: Bool)
    func update(_ batch: WriteBatch, userID: UserID, messageAt: Date)
}

protocol CustomerRepository {
    func create() -> Single<Void>
}

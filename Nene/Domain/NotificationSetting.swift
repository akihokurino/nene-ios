//
//  NotificationSetting.swift
//  Nene
//
//  Created by akiho on 2019/01/15.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

struct NotificationSetting {
    enum Topic: Int {
        case unknown = 0
        case chat = 1
        case bookingRemind = 2
    }
    
    let topic: Topic
    let isOn: Bool
}

protocol NotificationSettingRepository {
    func observe(userID: UserID) -> Observable<[NotificationSetting]>
    func update(_ batch: WriteBatch, userID: UserID, setting: NotificationSetting)
}

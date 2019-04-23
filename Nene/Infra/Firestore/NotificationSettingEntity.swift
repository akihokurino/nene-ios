//
//  NotificationSettingEntity.swift
//  Nene
//
//  Created by akiho on 2019/01/15.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct NotificationSettingEntity {
    let topic: Int
    let isOn: Bool
    
    static let collectionName = "notificationSettings"
    
    static func documentName(topic: NotificationSetting.Topic) -> String {
        return "topic-\(topic.rawValue)"
    }
    
    static let orderBy = "topic"
    
    static func from(setting: NotificationSetting) -> NotificationSettingEntity {
        return NotificationSettingEntity(topic: setting.topic.rawValue, isOn: setting.isOn)
    }
    
    static func to(data: [String: Any], converter: PrimitiveConverter) -> NotificationSetting {
        return NotificationSetting(
            topic: NotificationSetting.Topic(rawValue: converter.toInt(data["topic"])) ?? .unknown,
            isOn: converter.toBool(data["isOn"])
        )
    }
    
    func doc() -> [String: Any] {
        return [
            "topic": topic,
            "isOn": isOn,
        ]
    }
}

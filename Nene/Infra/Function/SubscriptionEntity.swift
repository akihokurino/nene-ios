//
//  SubscriptionEntity.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct SubscriptionEntity {
    let id: String
    let periodStart: Int
    let periodEnd: Int
   
    static func to(data: [String: Any], converter: PrimitiveConverter) -> Subscription {
        let start = Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["periodStart"])))
        let end = Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["periodEnd"])))
        return Subscription(
            id: converter.toString(data["id"]),
            periodStart: YearMonthDay.from(date: start),
            periodEnd: YearMonthDay.from(date: end)
        )
    }
}

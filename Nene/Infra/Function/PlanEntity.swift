//
//  PlanEntity.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct PlanEntity {
    let id: String
    let amount: Int
    let isActive: Bool
    let interval: String
    
    static func to(data: [String: Any], converter: PrimitiveConverter) -> Plan {
        return Plan(
            id: converter.toString(data["id"]),
            amount: converter.toInt(data["amount"]),
            interval: Plan.Interval(rawValue: converter.toString(data["interval"])) ?? .unknown
        )
    }
}

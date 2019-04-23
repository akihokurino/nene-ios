//
//  Plan.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift

struct Plan {
    enum Interval: String {
        case unknown
        case month
    }
    
    let id: String
    let amount: Int
    let interval: Interval
}

protocol PlanRepository {
    func getAll() -> Single<[Plan]>
}

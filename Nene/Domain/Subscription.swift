//
//  Subscription.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift

struct Subscription {
    let id: String
    let periodStart: YearMonthDay
    let periodEnd: YearMonthDay
}

protocol SubscriptionRepository {
    func getAll() -> Single<[Subscription]>
    func create(planId: String) -> Single<Void>
    func cancel() -> Single<Void>
}

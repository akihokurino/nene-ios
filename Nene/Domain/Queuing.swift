//
//  Queuing.swift
//  Nene
//
//  Created by akiho on 2019/02/14.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

struct Queuing {
    let userID: UserID
    let code: String
    let createdAt: Date
}

protocol QueuingRepository {
    func get(userID: UserID) -> Single<Queuing>
    func getCountByOlder(at: Date) -> Single<Int>
    func create(_ batch: WriteBatch, queuing: Queuing)
}

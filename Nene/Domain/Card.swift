//
//  Card.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift

struct Card {
    let id: String
    let expMonth: Int
    let expYear: Int
    let number: String
    let cvc: String
}

protocol CardRepository {
    func create(card: Card) -> Single<Void>
}

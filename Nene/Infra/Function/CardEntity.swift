//
//  CardEntity.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct CardEntity {
    let id: String
    let expMonth: Int
    let expYear: Int
    let number: String
    let cvc: String
    
    static func from(card: Card) -> CardEntity {
        return CardEntity(id: card.id,
                          expMonth: card.expMonth,
                          expYear: card.expYear,
                          number: card.number,
                          cvc: card.cvc)
    }
    
    func doc() -> [String: Any] {
        return [
            "id": id,
            "expMonth": expMonth,
            "expYear": expYear,
            "number": number,
            "cvc": cvc
        ]
    }
}

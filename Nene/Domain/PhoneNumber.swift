//
//  PhoneNumber.swift
//  Nene
//
//  Created by akiho on 2019/01/28.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct PhoneNumber {
    let value: String
    
    static func fromE164(_ phoneNumber: String) -> PhoneNumber? {
        if phoneNumber.prefix(3) != "+81" {
            return nil
        }
        return PhoneNumber(value: "0" + String(phoneNumber.dropFirst(3)))
    }
    
    func toE164() -> String {
        if value.count != 11 {
            return ""
        }
        return "+81" + String(value.dropFirst())
    }
    
    var local: String {
        if value.prefix(3) != "+81" {
            return ""
        }
        return "0" + String(value.dropFirst(3))
    }
}

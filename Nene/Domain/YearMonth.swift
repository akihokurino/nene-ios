//
//  YearMonth.swift
//  Nene
//
//  Created by akiho on 2019/01/19.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct YearMonth {
    let year: String
    let month: String
    
    static func from(date: Date) -> YearMonth {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        format.timeZone = TimeZone.current
        format.locale = Locale.current
        let dateString = format.string(from: date)
        return YearMonth(year: String(dateString.split(separator: "-")[0]),
                         month: String(dateString.split(separator: "-")[1]))
    }
    
    func toString() -> String {
        return "\(year)-\(month)"
    }
    
    func toExpireDate() -> String {
        return "\(month)/\(year)"
    }
}

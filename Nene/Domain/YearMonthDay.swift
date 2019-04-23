//
//  YearMonthDay.swift
//  Nene
//
//  Created by akiho on 2019/01/19.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct YearMonthDay {
    let year: String
    let month: String
    let day: String
    
    private let sample = ["01", "02", "03", "04", "05", "06", "07", "08", "09"]
    
    static func from(date: Date) -> YearMonthDay {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        format.timeZone = TimeZone.current
        format.locale = Locale.current
        let dateString = format.string(from: date)
        return YearMonthDay(year: String(dateString.split(separator: "-")[0]),
                            month: String(dateString.split(separator: "-")[1]),
                            day: String(dateString.split(separator: "-")[2]))
    }
    
    func toString() -> String {
        return "\(year)-\(month)-\(day)"
    }
    
    func equal(date: Date) -> Bool {
        let day = YearMonthDay.from(date: date)
        return day.toString() == toString()
    }
    
    func toTimestamp() -> Int {
        let date_formatter: DateFormatter = DateFormatter()
        date_formatter.locale = NSLocale(localeIdentifier: "ja") as Locale
        date_formatter.dateFormat = "yyyy-MM-dd"
        return Int(date_formatter.date(from: toString())?.timeIntervalSince1970 ?? 0)
    }
    
    var monthString: String {
        if sample.contains(month) {
            return String(month[month.index(month.startIndex, offsetBy: 1)...])
        }
        
        return month
    }
    
    var dayString: String {
        if sample.contains(day) {
            return String(day[day.index(day.startIndex, offsetBy: 1)...])
        }
        
        return day
    }
}

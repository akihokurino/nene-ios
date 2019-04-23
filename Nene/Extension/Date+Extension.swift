//
//  Date+Extension.swift
//  Nene
//
//  Created by akiho on 2019/01/19.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

extension Date {
    var jst: Date {
        return Date(timeInterval: 60 * 60 * 9, since: self)
    }
    
    func differenceInDay(_ date: Date) -> Int {
        let cal = Calendar(identifier: .gregorian)
        let lhs = cal.dateComponents([.year, .month, .day], from: self)
        let rhs = cal.dateComponents([.year, .month, .day], from: date)
        let components = cal.dateComponents([.day], from: lhs, to: rhs)
        return components.day!
    }
}

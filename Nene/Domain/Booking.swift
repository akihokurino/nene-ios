//
//  Booking.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift

struct Booking {
    let id: String
    let date: String
    let time: String
    let restaurantName: String
    let numberOfPeople: Int
    let subscriberName: String
    let seat: String
    let createdAt: Date
    let updatedAt: Date
    
    func dateString() -> String {
        let dateList = date.split(separator: "-")
        guard dateList.count == 3 else {
            return date
        }
        return "\(dateList[0])年\(dateList[1])月\(dateList[2])日"
    }
}

protocol BookingRepository {
    func observeByMonth(userID: UserID, yearMonth: YearMonth) -> Observable<[Booking]>
}

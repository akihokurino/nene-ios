//
//  BookingEntity.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

struct BookingEntity {
    let id: String
    let date: String
    let time: String
    let restaurantName: String
    let numberOfPeople: Int
    let subscriberName: String
    let seat: String
    let createdAt: Int
    let updatedAt: Int
    
    static let collectionName = "bookings"
    
    static func documentName(id: String) -> String {
        return id
    }
    
    static let orderBy = "date"
    
    static func from(booking: Booking) -> BookingEntity {
        return BookingEntity(
            id: booking.id,
            date: booking.date,
            time: booking.time,
            restaurantName: booking.restaurantName,
            numberOfPeople: booking.numberOfPeople,
            subscriberName: booking.subscriberName,
            seat: booking.seat,
            createdAt: Int(booking.createdAt.timeIntervalSince1970),
            updatedAt: Int(booking.updatedAt.timeIntervalSince1970)
        )
    }
    
    static func to(data: [String: Any], converter: PrimitiveConverter) -> Booking {
        return Booking(
            id: converter.toString(data["id"]),
            date: converter.toString(data["date"]),
            time: converter.toString(data["time"]),
            restaurantName: converter.toString(data["restaurantName"]),
            numberOfPeople: converter.toInt(data["numberOfPeople"]),
            subscriberName: converter.toString(data["subscriberName"]),
            seat: converter.toString(data["seat"]),
            createdAt: Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["createdAt"]))),
            updatedAt: Date(timeIntervalSince1970: TimeInterval(converter.toInt(data["updatedAt"])))
        )
    }
    
    func doc() -> [String: Any] {
        return [
            "id": id,
            "date": date,
            "time": time,
            "restaurantName": restaurantName,
            "numberOfPeople": numberOfPeople,
            "subscriberName": subscriberName,
            "seat": seat,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
}

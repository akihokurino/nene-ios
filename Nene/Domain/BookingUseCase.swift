//
//  BookingUseCase.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol BookingUseCase {
    func syncBooking(userID: UserID, yearMonth: YearMonth) -> Observable<[Booking]>
    func cancelBooking(userID: UserID, chatRoom: ChatRoom, booking: Booking, now: Date) -> Single<Void>
}

final class BookingUseCaseImpl: BookingUseCase {
    private let transaction: Transaction
    private let bookingRepository: BookingRepository
    private let messageRepository: MessageRepository
    private let idGenerator: IDGenerator
    
    init(transaction: Transaction,
         bookingRepository: BookingRepository,
         messageRepository: MessageRepository,
         idGenerator: IDGenerator) {
        self.transaction = transaction
        self.bookingRepository = bookingRepository
        self.messageRepository = messageRepository
        self.idGenerator = idGenerator
    }
    
    func syncBooking(userID: UserID, yearMonth: YearMonth) -> Observable<[Booking]> {
        return bookingRepository.observeByMonth(userID: userID, yearMonth: yearMonth)
    }
    
    func cancelBooking(userID: UserID, chatRoom: ChatRoom, booking: Booking, now: Date) -> Single<Void> {
        let messageRepository = self.messageRepository
        
        let text = "日時:\(booking.dateString()) \(booking.time)\n予定：\(booking.restaurantName)\n予約名：\(booking.subscriberName)\n予約人数：\(booking.numberOfPeople)人\n席：\(booking.seat)\n\nの予約キャンセルをお願いします。"
        let message = Message(
            id: idGenerator.generate(),
            fromUserID: userID,
            toUserID: StaticConfig.adminUserID,
            text: text,
            imageURL: nil,
            createdAt: now,
            isMine: false
        )
        
        return transaction.batch(executions: [
            { batch in
                messageRepository.create(batch, chatRoom: chatRoom, message: message)
            }
            ])
    }
}

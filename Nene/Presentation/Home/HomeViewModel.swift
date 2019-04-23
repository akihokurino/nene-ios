//
//  HomeViewModel.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
        let bookingUseCase: BookingUseCase
        let chatRoomUseCase: ChatRoomUseCase
    }
    
    struct Input {
        let viewWillAppear: Driver<Void>
        let selectedDay: Driver<YearMonthDay>
        let selectedMonth: Driver<YearMonth>
        let cancelBooking: Driver<Booking>
    }
    
    struct Output {
        let allBookings: Driver<[Booking]>
        let dayBookings: Driver<[Booking]>
        let isExecuting: Driver<Bool>
        let error: Driver<Error>
        let selectedMonth: Driver<YearMonth>
        let selectedDay: Driver<YearMonthDay>
        let cancelBooking: Driver<Void>
    }
    
    private let userUseCase: UserUseCase
    private let bookingUseCase: BookingUseCase
    private let chatRoomUseCase: ChatRoomUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
        bookingUseCase = dependency.bookingUseCase
        chatRoomUseCase = dependency.chatRoomUseCase
    }
    
    func transform(input: Input) -> Output {
        let bookingUseCase = self.bookingUseCase
        let userUseCase = self.userUseCase
        let chatRoomUseCase = self.chatRoomUseCase
       
        let now = Date()
        let thisMonth = Driver.just(YearMonth.from(date: now))
        let thisDay = Driver.just(YearMonthDay.from(date: now))
        
        let meAction = Driver.just(())
            .flatMap { _ -> Driver<Action<User>> in
                let source = userUseCase.me()
                return Action.makeDriver(source)
            }
        
        let getBookingsAction = Driver.merge(
            input.selectedMonth,
            meAction.elements.flatMap { _ in return thisMonth })
            .withLatestFrom(meAction.elements) { ($0, $1) }
            .flatMap { yearMonth, user -> Driver<Action<[Booking]>> in
                let source = bookingUseCase.syncBooking(userID: user.toUserID, yearMonth: yearMonth)
                return Action.makeDriver(source)
            }
        
        let initChatRoomAction = meAction.elements
            .flatMap { user -> Driver<Action<ChatRoom>> in
                let source = chatRoomUseCase.initRoom(userID: user.toUserID, now: Date())
                return Action.makeDriver(source)
            }
        
        let cancelBookingAction = input.cancelBooking
            .withLatestFrom(meAction.elements) { ($0, $1) }
            .withLatestFrom(initChatRoomAction.elements) { ($0, $1) }
            .flatMap { pair, chatRoom -> Driver<Action<Void>> in
                let source = bookingUseCase.cancelBooking(userID: pair.1.toUserID,
                                                          chatRoom: chatRoom,
                                                          booking: pair.0,
                                                          now: Date())
                return Action.makeDriver(source)
            }
        
        let allBookings = Driver.merge(getBookingsAction.elements)
        
        let isExecuting = Driver.merge(getBookingsAction.isExecuting, meAction.isExecuting)
        
        // TODO: logout時にgetBookでエラーが出る問題
        let error = Driver.merge(meAction.error,
                                 initChatRoomAction.error,
//                                 getBookingsAction.error,
                                 cancelBookingAction.error)
        
        let selectedMonth = Driver.merge(thisMonth, input.selectedMonth)
        let selectedDay = Driver.merge(thisDay, input.selectedDay)
        
        let dayBookings = Driver.combineLatest(allBookings, selectedDay)
            .map({ bookings, day -> [Booking] in
                return bookings.filter { $0.date == day.toString() }
            })
        
        let cancelBooking = cancelBookingAction.elements
        
        return Output(allBookings: allBookings,
                      dayBookings: dayBookings,
                      isExecuting: isExecuting,
                      error: error,
                      selectedMonth: selectedMonth,
                      selectedDay: selectedDay,
                      cancelBooking: cancelBooking)
    }
}


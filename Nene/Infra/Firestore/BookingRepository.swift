//
//  BookingRepository.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

final class BookingRepositoryImpl: BookingRepository {
    private let db: Firestore
    private let converter: PrimitiveConverter
    
    init(db: Firestore, converter: PrimitiveConverter) {
        self.db = db
        self.converter = converter
    }
    
    func observeByMonth(userID: UserID, yearMonth: YearMonth) -> Observable<[Booking]> {
        let db = self.db
        let converter = self.converter
        let subject = PublishSubject<[Booking]>()
        
        db.collection(UserEntity.collectionName)
            .document(UserEntity.documentName(userID: userID))
            .collection(BookingEntity.collectionName)
            .whereField("dateYear", isEqualTo: yearMonth.year)
            .whereField("dateMonth", isEqualTo: yearMonth.month)
            .order(by: BookingEntity.orderBy)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    subject.onError(AppError.toInternalError(error))
                    return
                }
                
                guard let document = documentSnapshot else {
                    subject.onError(AppError.toInternalError())
                    return
                }
                
                let bookings = document.documents.map { snapshot -> Booking in
                    return BookingEntity.to(data: snapshot.data(), converter: converter)
                }
                
                subject.onNext(bookings)
            }
        
        return subject.asObservable()
    }
}

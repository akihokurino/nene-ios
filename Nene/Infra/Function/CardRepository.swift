//
//  CardRepository.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class CardRepositoryImpl: CardRepository {
    private let functions: Functions
    private let converter: PrimitiveConverter
    
    init(functions: Functions, converter: PrimitiveConverter) {
        self.functions = functions
        self.converter = converter
    }
    
    func create(card: Card) -> Single<Void> {
        let functions = self.functions
        let entity = CardEntity.from(card: card)
        
        return Single<Void>
            .create(subscribe: { observer -> Disposable in
                functions.httpsCallable("registerCard").call(entity.doc()) { (result, error) in
                    if let error = error as NSError? {
                        observer(.error(AppError.toInternalError(error)))
                        return
                    }
                    
                    observer(.success(()))
                }
                
                return Disposables.create()
            })
    }
}

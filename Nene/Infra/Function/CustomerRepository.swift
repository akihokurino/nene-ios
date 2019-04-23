//
//  CustomerRepository.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class CustomerRepositoryImpl: CustomerRepository {
    private let functions: Functions
    private let converter: PrimitiveConverter
    
    init(functions: Functions, converter: PrimitiveConverter) {
        self.functions = functions
        self.converter = converter
    }
    
    func create() -> Single<Void> {
        let functions = self.functions
        
        return Single<Void>
            .create(subscribe: { observer -> Disposable in
                functions.httpsCallable("registerCustomer").call([:]) { (result, error) in
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

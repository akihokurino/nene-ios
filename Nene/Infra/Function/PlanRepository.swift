//
//  PlanRepository.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class PlanRepositoryImpl: PlanRepository {
    private let functions: Functions
    private let converter: PrimitiveConverter
    
    init(functions: Functions, converter: PrimitiveConverter) {
        self.functions = functions
        self.converter = converter
    }
    
    func getAll() -> Single<[Plan]> {
        let functions = self.functions
        let converter = self.converter
        
        return Single<[Plan]>
            .create(subscribe: { observer -> Disposable in
                functions.httpsCallable("getAllPlans").call([:]) { (result, error) in
                    if let error = error as NSError? {                        
                        observer(.error(AppError.toInternalError(error)))
                        return
                    }
                    
                    guard let items = (result?.data as? [String: Any])?["items"] as? [[String: Any]] else {
                        observer(.error(AppError.toInternalError()))
                        return
                    }
                    
                    observer(.success(items.map { item -> Plan in
                        return PlanEntity.to(data: item, converter: converter)
                    }))
                }
                
                return Disposables.create()
            })
    }
}

//
//  SubscriptionRepository.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class SubscriptionRepositoryImpl: SubscriptionRepository {
    private let functions: Functions
    private let converter: PrimitiveConverter
    
    init(functions: Functions, converter: PrimitiveConverter) {
        self.functions = functions
        self.converter = converter
    }
    
    func getAll() -> Single<[Subscription]> {
        let functions = self.functions
        let converter = self.converter
        
        return Single<[Subscription]>
            .create(subscribe: { observer -> Disposable in
                functions.httpsCallable("getAllSubscriptions").call([:]) { (result, error) in
                    if let error = error as NSError? {
                        observer(.error(AppError.toInternalError(error)))
                        return
                    }
                    
                    guard let items = (result?.data as? [String: Any])?["items"] as? [[String: Any]] else {
                        observer(.error(AppError.toInternalError()))
                        return
                    }
                    
                    observer(.success(items.map { item -> Subscription in
                        return SubscriptionEntity.to(data: item, converter: converter)
                    }))
                }
                
                return Disposables.create()
            })
    }
    
    func create(planId: String) -> Single<Void> {
        let functions = self.functions
        
        return Single<Void>
            .create(subscribe: { observer -> Disposable in
                functions.httpsCallable("subscribe").call(["planId": planId]) { (result, error) in
                    if let error = error as NSError? {
                        observer(.error(AppError.toInternalError(error)))
                        return
                    }
                    
                    observer(.success(()))
                }
                
                return Disposables.create()
            })
    }
    
    func cancel() -> Single<Void> {
        let functions = self.functions
        
        return Single<Void>
            .create(subscribe: { observer -> Disposable in
                functions.httpsCallable("cancel").call([:]) { (result, error) in
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

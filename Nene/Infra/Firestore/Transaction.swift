//
//  Transaction.swift
//  Nene
//
//  Created by akiho on 2019/02/24.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

typealias BatchExecution = ((WriteBatch) -> Void)

protocol Transaction {
    func batch(executions: [BatchExecution]) -> Single<Void>
}

final class TransactionImpl: Transaction {
    private let db: Firestore
    
    init(db: Firestore) {
        self.db = db
    }
    
    func batch(executions: [BatchExecution]) -> Single<Void> {
        let batch = db.batch()
        
        executions.forEach { execution in
            execution(batch)
        }
        
        return Single<Void>
            .create(subscribe: { observer -> Disposable in
                batch.commit() { error in
                    if let error = error {
                        observer(.error(AppError.toInternalError(error)))
                        return
                    }
                    
                    observer(.success(()))
                }
                
                return Disposables.create()
            })
    }
}

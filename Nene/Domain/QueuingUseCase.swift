//
//  QueuingUseCase.swift
//  Nene
//
//  Created by akiho on 2019/02/14.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Foundation
import RxSwift
import RxCocoa
import SwiftyUserDefaults

protocol QueuingUseCase {
    func registerCode(code: String)
    func currentLine(userID: UserID) -> Single<Int>
}

final class QueuingUseCaseImpl: QueuingUseCase {
    private let queuingRepository: QueuingRepository
    
    init(queuingRepository: QueuingRepository) {
        self.queuingRepository = queuingRepository
    }
    
    func registerCode(code: String) {
        Defaults[.registerCode] = code
    }
    
    func currentLine(userID: UserID) -> Single<Int> {
        let queuingRepository = self.queuingRepository
        return queuingRepository.get(userID: userID)
            .flatMap { queuing -> Single<Int> in
                return queuingRepository.getCountByOlder(at: queuing.createdAt)
            }
            .catchError { error -> Single<Int> in
                if AppError.isNotExistError(error) {
                    return Single.just(0)
                }
                
                return Single.error(error)
            }
    }
}

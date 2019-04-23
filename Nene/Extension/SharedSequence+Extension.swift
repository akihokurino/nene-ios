//
//  SharedSequence+Extension.swift
//  Neon
//
//  Created by akiho on 2019/01/06.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension SharedSequence {
    func mapToVoid() -> SharedSequence<S, Void> {
        return map { _ in }
    }
}

//
//  Action.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ActionConvertible {
    associatedtype Element
    var action: Action<Element> { get }
}

enum Action<Element>: ActionConvertible {
    case started
    case succeeded(Element)
    case failed(Error)
    
    var action: Action<Element> {
        return self
    }
    
    var isExecuting: Bool {
        switch self {
        case .started:
            return true
        case .succeeded, .failed:
            return false
        }
    }
    
    static func makeDriver<O: ObservableConvertibleType>(_ source: O) -> Driver<Action<Element>> where O.E == Element {
        return source.asObservable()
            .map { Action.succeeded($0) }
            .asDriver { Driver.just(Action.failed($0)) }
            .startWith(Action.started)
    }
}

extension SharedSequence where E: ActionConvertible {
    var isExecuting: SharedSequence<SharingStrategy, Bool> {
        return map { $0.action.isExecuting }.startWith(false)
    }
    
    var elements: SharedSequence<SharingStrategy, Element.Element> {
        return flatMap { convertible in
            switch convertible.action {
            case .succeeded(let value):
                return SharedSequence<SharingStrategy, Element.Element>.just(value)
            case .started, .failed:
                return SharedSequence<SharingStrategy, Element.Element>.empty()
            }
        }
    }
    
    var error: SharedSequence<SharingStrategy, Error> {
        return flatMap { convertible in
            switch convertible.action {
            case .failed(let error):
                return SharedSequence<SharingStrategy, Error>.just(error)
            case .started, .succeeded:
                return SharedSequence<SharingStrategy, Error>.empty()
            }
        }
    }
}


//
//  AlertControllerBuilder.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

final class AlertControllerBuilder {
    private let title: String?
    private let message: String?
    private let preferredStyle: UIAlertController.Style
    
    private(set) var actions: [UIAlertAction]
    
    private init(title: String?, message: String?, preferredStyle: UIAlertController.Style) {
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        self.actions = []
    }
}

extension AlertControllerBuilder {
    static func makeBuilder(title: String? = nil, message: String? = nil, preferedStyle: UIAlertController.Style) -> AlertControllerBuilder {
        return AlertControllerBuilder(title: title, message: message, preferredStyle: preferedStyle)
    }
    
    func addAction(title: String? = nil, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> AlertControllerBuilder {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        actions.append(action)
        return self
    }
    
    func build() -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach(alertController.addAction(_:))
        return alertController
    }
    
    func build(with error: Error) -> UIAlertController {
        var title = "エラーが発生しました"
        var body = ""
        
        if let appError = error as? AppError {
            switch appError {
            case .alreadyExist(_, let message):
                body = message
            case .notExist(_, let message):
                body = message
            case .internalError(_, let message, _):
                body = message
            case .simpleError(let message):
                body = message
            case .notLogin(_, let message):
                body = message
            case .invalidPinCode(_, let message):
                body = message
            case .expireFreePlan(_, let message):
                body = message
            case .inputError(_, let message):
                title = message
                body = ""
            }
        }
        
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        actions.forEach(alertController.addAction(_:))
        return alertController
    }
    
    func build(title: String, body: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        actions.forEach(alertController.addAction(_:))
        return alertController
    }
}


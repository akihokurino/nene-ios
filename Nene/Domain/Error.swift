//
//  Error.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

enum AppError: Error {
    case simpleError(message: String)
    
    case alreadyExist(code: Int, message: String)
    case notExist(code: Int, message: String)
    case internalError(code: Int, message: String, error: Error?)
    case notLogin(code: Int, message: String)
    case invalidPinCode(code: Int, message: String)
    case expireFreePlan(code: Int, message: String)
    case inputError(code: Int, message: String)
    
    static func toInputError(message: String) -> AppError {
        return .inputError(code: 400, message: message)
    }

    static func toNotLoginError() -> AppError {
        return .notLogin(code: 401, message: "ログインしてください")
    }
    
    static func toInternalError() -> AppError {
        return .internalError(code: 500, message: "不明なエラーが発生しました", error: nil)
    }
    
    static func toInternalError(_ error: Error) -> AppError {
        return .internalError(code: 500, message: "不明なエラーが発生しました", error: error)
    }
    
    static func toNotExistError() -> AppError {
        return .notExist(code: 404, message: "リソースが存在しません")
    }
    
    static func toInvalidPinCode() -> AppError {
        return .invalidPinCode(code: 400, message: "認証コードが間違っています。再度ご確認ください。")
    }
    
    static func toExpireFreePlan() -> AppError {
        return .expireFreePlan(code: 403, message: "フリートライアルが終了しています。")
    }
    
    static func isNotExistError(_ error: Error) -> Bool {
        guard let appError = error as? AppError else {
            return false
        }
        
        switch appError {
        case .notExist:
            return true
        default:
            return false
        }
    }
    
    static func isNotLoginError(_ error: Error) -> Bool {
        guard let appError = error as? AppError else {
            return false
        }
        
        switch appError {
        case .notLogin:
            return true
        default:
            return false
        }
    }
    
    static func isInvalidPinCode(_ error: Error) -> Bool {
        guard let appError = error as? AppError else {
            return false
        }
        
        switch appError {
        case .invalidPinCode:
            return true
        default:
            return false
        }
    }
    
    static func isExpireFreePlan(_ error: Error) -> Bool {
        guard let appError = error as? AppError else {
            return false
        }
        
        switch appError {
        case .expireFreePlan:
            return true
        default:
            return false
        }
    }
}

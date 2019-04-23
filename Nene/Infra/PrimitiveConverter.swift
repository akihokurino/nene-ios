//
//  PrimitiveConverter.swift
//  Neon
//
//  Created by akiho on 2019/01/07.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

protocol PrimitiveConverter {
    func toString(_ item: Any?) -> String
    func toInt(_ item: Any?) -> Int
    func toIntArray(_ item: Any?) -> [Int]
    func toBool(_ item: Any?) -> Bool
}

final class PrimitiveConverterImpl: PrimitiveConverter {
    func toString(_ item: Any?) -> String {
        return item as? String ?? ""
    }
    
    func toInt(_ item: Any?) -> Int {
        return item as? Int ?? 0
    }
    
    func toIntArray(_ item: Any?) -> [Int] {
        return item as? [Int] ?? []
    }
    
    func toBool(_ item: Any?) -> Bool {
        return item as? Bool ?? false
    }
}

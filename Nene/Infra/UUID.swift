//
//  UUID.swift
//  Neon
//
//  Created by akiho on 2019/01/06.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

final class IDGeneratorImpl: IDGenerator {
    func generate() -> String {
        return UUID().uuidString
    }
}

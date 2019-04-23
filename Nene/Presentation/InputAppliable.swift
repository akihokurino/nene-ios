//
//  InputAppliable.swift
//  Neon
//
//  Created by akiho on 2019/01/06.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

protocol InputAppliable {
    associatedtype Input
    func apply(input: Input)
}

extension InputAppliable {
    func applied(input: Input) -> Self {
        apply(input: input)
        return self
    }
}

//
//  InjectableViewModel.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation

protocol InjectableViewModel {
    associatedtype Dependency
    associatedtype Input
    associatedtype Output
    
    init(dependency: Self.Dependency)
    
    func transform(input: Self.Input) -> Self.Output
}


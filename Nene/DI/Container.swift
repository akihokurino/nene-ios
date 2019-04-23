//
//  Container.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import Swinject

extension Container {
    static let sharedResolver = assemblers.resolver
    
    private static let assemblers = Assembler([
        InfraAssembly(),
        DomainAssembly()
    ])
}

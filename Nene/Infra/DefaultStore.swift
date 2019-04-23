//
//  DefaultStore.swift
//  Nene
//
//  Created by akiho on 2019/01/28.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let verificationID = DefaultsKey<String>("verificationID")
    static let registerCode = DefaultsKey<String>("registerCode")
    static let isAlreadyShownWalkThrough = DefaultsKey<Bool>("isAlreadyShownWalkThrough")
}

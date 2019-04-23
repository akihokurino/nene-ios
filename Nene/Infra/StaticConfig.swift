//
//  StaticConfig.swift
//  Nene
//
//  Created by akiho on 2019/01/27.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

struct StaticConfig {
    static let adminUserID: UserID = UserID(id: "RW8QIzQPVtdZwHmbyM0u6ATpd1L2")
    
    static let settingURL: URL = URL(string: UIApplication.openSettingsURLString)!
    
    static let termsURL: URL = URL(string: "https://ne-ne.net/riyo.pdf")!
    static let privacyPolicyURL: URL = URL(string: "https://ne-ne.net/privacy.pdf")!
    static let commercialCodeURL: URL = URL(string: "https://ne-ne.net/law.pdf")!
}

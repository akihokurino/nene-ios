//
//  UIFont+Extension.swift
//  Neon
//
//  Created by akiho on 2019/01/11.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

extension UIFont {
    static func bold(size: CGFloat) -> UIFont {
        return UIFont(name: "HiraKakuProN-W6", size: size)!
    }
    
    static func normal(size: CGFloat) -> UIFont {
        return UIFont(name: "HiraKakuProN-W3", size: size)!
    }
}

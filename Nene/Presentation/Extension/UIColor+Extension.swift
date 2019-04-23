//
//  UIColor+Extension.swift
//  Neon
//
//  Created by akiho on 2019/01/10.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = hex.map { String($0) } + Array(repeating: "0", count: max(6 - hex.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0) / 255.0
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0) / 255.0
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    static var primary: UIColor {
        return UIColor(hex: "1E1E1E")
    }
    
    static var background: UIColor {
        return UIColor(hex: "111111")
    }
    
    static var activeColor: UIColor {
        return UIColor(hex: "CCBBA8")
    }
    
    static var inactiveColor: UIColor {
        return UIColor(hex: "7D7C7C")
    }
    
    static var borderGray: UIColor {
        return UIColor(hex: "D3DBD8")
    }
}

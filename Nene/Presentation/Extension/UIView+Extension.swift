//
//  UIView+Extension.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            
            return UIColor(cgColor: cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIView {
    var recursiveSubviews: [UIView] {
        func recursiveSubviews(of view: UIView) -> [UIView] {
            var recursiveSubviews = view.subviews
            for subview in view.subviews {
                recursiveSubviews += subview.recursiveSubviews
            }
            return recursiveSubviews
        }
        return recursiveSubviews(of: self)
    }
    
    func embed(view: UIView) {
        view.frame = bounds
        addSubview(view)
    }
    
    func roundCorners(_ corners: UIRectCorner){
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 8.0, height: 8.0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}


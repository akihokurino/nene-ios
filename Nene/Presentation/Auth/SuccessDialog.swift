//
//  SuccessDialog.swift
//  Nene
//
//  Created by akiho on 2019/02/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SuccessDialog: UIView, InputAppliable {
    
    static let width: CGFloat = 192
    static let height: CGFloat = 169
    
    static func instance(frame: CGRect) -> SuccessDialog {
        let view = R.nib.successDialog.firstView(owner: nil, options: nil)!
        view.frame = frame
        return view
    }

    @IBOutlet private weak var messageLabel: UILabel!
    
    typealias Input = String
    
    func apply(input: Input) {
        messageLabel.text = input
    }
    
    func show(callback: @escaping () -> Void) {
        alpha = 0.0
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.alpha = 1.0
        }, completion: { _ in
            callback()
        })
    }
}

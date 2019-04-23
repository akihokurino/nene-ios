//
//  SubscriptionCancelView.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SubscriptionCancelView: UIView, InputAppliable {
    
    static func instance(frame: CGRect) -> SubscriptionCancelView {
        let view = R.nib.subscriptionCancelView.firstView(owner: nil, options: nil)!
        view.frame = frame
        return view
    }
    
    @IBOutlet fileprivate weak var cancelButton: UIButton!
    @IBOutlet private weak var expireDateLabel: UILabel!
    
    typealias Input = Subscription
    
    func apply(input: Input) {
        let subscription = input
        expireDateLabel.text = "有効期限：\(subscription.periodEnd.toString())"
    }
}

extension Reactive where Base: SubscriptionCancelView {
    var didTapCancelBtn: Driver<Void> {
        return base.cancelButton.rx.tap.asDriver()
    }
}


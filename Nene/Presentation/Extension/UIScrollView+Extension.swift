//
//  UIScrollView+Extension.swift
//  Nene
//
//  Created by akiho on 2019/01/19.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    var reachedBottom: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else {
                    return Observable.empty()
                }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                return y > threshold ? .just(()) : .empty()
            }
            .throttle(1, latest: false, scheduler: MainScheduler.instance)
        
        return ControlEvent(events: observable)
    }
    
    var scrollProgress: ControlEvent<CGFloat> {
        let contentSize = observe(CGSize.self, "contentSize")
            .map { $0 ?? CGSize.zero }
            .startWith(base.contentSize)
        
        let observable = Observable.combineLatest(contentSize, contentOffset) { size, offset -> CGFloat in
            return size.width > 0.0 ? offset.x / size.width : 0.0
        }
        
        return ControlEvent(events: observable)
    }
}

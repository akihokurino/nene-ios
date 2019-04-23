//
//  UIViewController+Extension.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

typealias HUD = SVProgressHUD

extension Reactive where Base: UIViewController {
    private func controlEvent(for selector: Selector) -> ControlEvent<Void> {
        return ControlEvent(events: sentMessage(selector).map { _ in })
    }
    
    var viewWillAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillAppear))
    }
    
    var viewDidAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidAppear))
    }
    
    var viewWillDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillDisappear))
    }
    
    var viewDidDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidDisappear))
    }
    
    var viewDidLayoutSubViews: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidLayoutSubviews))
    }
    
    var isHUDAnimating: Binder<Bool> {
        return Binder(base) { _, isAnimating in
            if isAnimating {
                HUD.setDefaultMaskType(.clear)
                HUD.show()
            } else {
                HUD.dismiss()
            }
        }
    }
    
    func dismiss<E>() -> AnyObserver<E> {
        return AnyObserver { [weak base] event in
            switch event {
            case .next:
                base?.dismiss(animated: true)
                
            case .error, .completed:
                break
            }
        }
    }
    
    func pop<E>() -> AnyObserver<E> {
        return AnyObserver { [weak base] event in
            switch event {
            case .next:
                base?.navigationController?.popViewController(animated: true)
                
            case .error, .completed:
                break
            }
        }
    }
}

extension UIViewController {
    func showHUD(image: UIImage, message: String, duration: Double = 1.0, size: CGSize = CGSize(width: 150, height: 150)) {
        HUD.setMinimumSize(size)
        HUD.setDefaultMaskType(.clear)
        HUD.show(image, status: message)
        
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + duration) {
            DispatchQueue.main.async {
                HUD.dismiss()
            }
        }
    }
    
    func showAlert(with error: Error, completionHandler: (() -> Void)? = nil) {
        let alertViewController = AlertControllerBuilder
            .makeBuilder(preferedStyle: .alert)
            .addAction(title: "OK", style: .default) { _ in
                completionHandler?()
            }
            .build(with: error)
        
        present(alertViewController, animated: true)
    }
    
    func showAlert(title: String, message: String, completionHandler: (() -> Void)? = nil) {
        let alertViewController = AlertControllerBuilder
            .makeBuilder(preferedStyle: .alert)
            .addAction(title: "OK", style: .default) { _ in
                completionHandler?()
            }
            .build(title: title, body: message)
        
        present(alertViewController, animated: true)
    }
    
    func embed(_ childViewController: UIViewController, to view: UIView) {
        childViewController.view.frame = view.bounds
        view.addSubview(childViewController.view)
        addChild(childViewController)
        childViewController.didMove(toParent: self)
    }
    
    func replace(_ childViewController: UIViewController, to view: UIView) {
        for viewController in children {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
        
        embed(childViewController, to: view)
    }
}


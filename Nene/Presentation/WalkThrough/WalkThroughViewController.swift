//
//  WalkThroughViewController.swift
//  Nene
//
//  Created by akiho on 2019/03/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WalkThroughViewController: UIViewController {
    
    static func instantiate() -> WalkThroughViewController {
        return R.storyboard.walkThrough.walkThroughViewController()!
    }
    
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var controlContainerHeight: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        children.forEach {
            ($0 as? WalkThroughPageViewController)?.customDelegate = self
        }

        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window!.safeAreaInsets.bottom
            controlContainerHeight.constant = controlContainerHeight.constant + bottomPadding
        }
        
        bind()
    }
    
    private func bind() {
        let vm = WalkThroughViewModel(
            dependency: .init(
                userUseCase: DomainAssembly.injectUserUseCase()
            )
        )
        
        let output = vm.transform(input: .init(
            didTapStartButton: startButton.rx.tap.asDriver()
        ))
        
        output.startWithMe
            .drive(onNext: { me in
                guard let me = me else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let nav = NavigationController(rootViewController: PhoneNumberBySignUpViewController.instantiate())
                        UIApplication.shared.keyWindow?.rootViewController = nav
                    }
                    return
                }
                
                if me.isWaiting {
                    let nav = NavigationController(rootViewController: QueuingListViewController.instantiate())
                    UIApplication.shared.keyWindow?.rootViewController = nav
                } else {
                    UIApplication.shared.keyWindow?.rootViewController = TabBarViewController.instantiate()
                }
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] in
                self?.showAlert(with: $0)
            })
            .disposed(by: disposeBag)
    }
}

extension WalkThroughViewController: WalkThroughPageViewControllerDelegate {
    func onChangePage(index: Int) {
        pageControl.currentPage = index
    }
}

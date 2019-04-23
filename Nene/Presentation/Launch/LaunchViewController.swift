//
//  LaunchViewController.swift
//  Nene
//
//  Created by akiho on 2019/02/14.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LaunchViewController: UIViewController {
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    private func bind() {
        let vm = LaunchViewModel(
            dependency: .init(
                userUseCase: DomainAssembly.injectUserUseCase()
            )
        )
        
        let output = vm.transform(input: .init())
        
        output.meWithNeedWalkThrough
            .drive(onNext: { meWithNeedWalkThrough in
                let isAlready = meWithNeedWalkThrough.1
                guard isAlready else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        UIApplication.shared.keyWindow?.rootViewController = WalkThroughViewController.instantiate()
                    }
                    return
                }
                
                guard let me = meWithNeedWalkThrough.0 else {
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

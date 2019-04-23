//
//  QueuingListViewController.swift
//  Nene
//
//  Created by akiho on 2019/02/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class QueuingListViewController: UIViewController {
    
    static func instantiate() -> QueuingListViewController {
        return R.storyboard.queuingList.queuingListViewController()!
    }

    @IBOutlet private weak var waitingLabel: UILabel!
    @IBOutlet private weak var pushNotificationButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let willEnterForeground: PublishSubject<Void> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.movedToForeground),
            name: Notification.Name(rawValue:"willEnterForeground"),
            object: nil)
        
        bind()
    }
    
    private func bind() {
        let vm = QueuingListViewModel(
            dependency: .init(
                userUseCase: DomainAssembly.injectUserUseCase(),
                queuingUseCase: DomainAssembly.injectQueuingUseCase(),
                notificationSettingUseCase: DomainAssembly.injectNotificationSettingUseCase()
            )
        )
        
        let output = vm.transform(input: .init(
            willEnterForeground: willEnterForeground.asDriver(onErrorDriveWith: .empty()),
            viewWillAppear: rx.viewWillAppear.asDriver(),
            didTapNotificationButton: pushNotificationButton.rx.tap.asDriver()
        ))
        
        output.me
            .drive(onNext: { user in
                if !user.isWaiting {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        UIApplication.shared.keyWindow?.rootViewController = TabBarViewController.instantiate()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.currentLine
            .drive(onNext: { [weak self] line in
                self?.waitingLabel.text = "\(line)人"
            })
            .disposed(by: disposeBag)
        
        output.isExecuting
            .drive(rx.isHUDAnimating)
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] in
                self?.showAlert(with: $0)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func movedToForeground(notification: Notification?) {
        willEnterForeground.onNext(())
    }
}

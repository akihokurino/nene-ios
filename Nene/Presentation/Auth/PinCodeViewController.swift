//
//  PinCodeViewController.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PinCodeViewController: UIViewController {
    
    static func instantiate() -> PinCodeViewController {
        return R.storyboard.pinCode.pinCodeViewController()!
    }

    @IBOutlet private weak var enterPinCodeContainer: UIView!
    @IBOutlet private weak var sendSMSButton: UIButton!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var dialogContainer: UIView!
    
    private let pinCode: PublishSubject<String> = PublishSubject()
    private let disposeBag = DisposeBag()
    private var successDialog: SuccessDialog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        successDialog = SuccessDialog.instance(frame: dialogContainer.bounds)
        dialogContainer.addSubview(successDialog)
        dialogContainer.isHidden = true

        bind()
    }
    
    private func bind() {
        let enterPinCodeVC = EnterPincodeViewController.instantiate(delegate: self)
        replace(enterPinCodeVC, to: enterPinCodeContainer)
        
        let vm = PinCodeViewModel(dependency: .init(
            userUseCase: DomainAssembly.injectUserUseCase()
            ))
        
        let output = vm.transform(input: .init(
            didInputPinCode: pinCode.asDriver(onErrorDriveWith: .empty())
        ))
        
        output.login
            .do(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .drive(onNext: { [weak self] user in
                if user.isWaiting {
                    self?.successDialog.apply(input: "待機リストに登録しました")
                    self?.dialogContainer.isHidden = false
                    self?.successDialog.show {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let nav = NavigationController(rootViewController: QueuingListViewController.instantiate())
                            UIApplication.shared.keyWindow?.rootViewController = nav
                        }
                    }
                } else {
                    self?.successDialog.apply(input: "認証が完了しました")
                    self?.dialogContainer.isHidden = false
                    self?.successDialog.show {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            UIApplication.shared.keyWindow?.rootViewController = TabBarViewController.instantiate()
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.isExecuting
            .drive(rx.isHUDAnimating)
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] in
                if AppError.isInvalidPinCode($0) {
                    self?.showAlert(
                        title: "認証コードが間違っています",
                        message: "認証コードが間違っています。再度ご確認ください")
                    enterPinCodeVC.reset()
                } else {
                    self?.showAlert(with: $0)
                    enterPinCodeVC.reset()
                }
            })
            .disposed(by: disposeBag)
        
        sendSMSButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                enterPinCodeVC.reset()
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension PinCodeViewController: EnterPincodeViewControllerDelegate {
    func didEnterPincode(_ pincode: String) {
        self.pinCode.onNext(pincode)
    }
}

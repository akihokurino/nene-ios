//
//  PhoneNumberBySignUpViewController.swift
//  Nene
//
//  Created by akiho on 2019/02/15.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PhoneNumberBySignUpViewController: UIViewController {

    static func instantiate() -> PhoneNumberBySignUpViewController {
        return R.storyboard.phoneNumberBySignUp.phoneNumberBySignUpViewController()!
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var phoneNumberField: UITextField!
    @IBOutlet private weak var sendSMSButton: UIButton!
    @IBOutlet private weak var termsButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var codeButton: UIButton!
    @IBOutlet private weak var codeField: UITextField!
    @IBOutlet private weak var phoneNumberFieldMarginTop: NSLayoutConstraint!
    @IBOutlet private weak var codeFieldMarginTop: NSLayoutConstraint!
    @IBOutlet private weak var codeFieldContainer: UIView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeFieldContainer.isHidden = true
        codeFieldMarginTop.constant = 0
        phoneNumberFieldMarginTop.constant = 70
                
        bind()
    }
    
    private func bind() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        containerView.addGestureRecognizer(tapGestureRecognizer)
        
        let vm = PhoneNumberBySignUpViewModel(dependency: .init(
            userUseCase: DomainAssembly.injectUserUseCase(),
            queuingUseCase: DomainAssembly.injectQueuingUseCase()
        ))
        
        let output = vm.transform(input: .init(
            code: codeField.rx.text.orEmpty.asDriver(),
            phoneNumber: phoneNumberField.rx.text.orEmpty.asDriver(),
            didTapSendSMSButton: sendSMSButton.rx.tap.asDriver()
        ))
        
        output.sendSMS
            .drive(onNext: { [weak self] in
                let vc = PinCodeViewController.instantiate()
                self?.navigationController?.pushViewController(vc, animated: true)
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
        
        codeButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.codeButton.isHidden = true
                self?.codeFieldContainer.isHidden = false
                self?.codeFieldMarginTop.constant = 32
                self?.phoneNumberFieldMarginTop.constant = 92
            })
            .disposed(by: disposeBag)
        
        loginButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                let vc = PhoneNumberViewController.instantiate()
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        termsButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                let vc = WebViewController.instantiate(title: "利用規約", url: StaticConfig.termsURL)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

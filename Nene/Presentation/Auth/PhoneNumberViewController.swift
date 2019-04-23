//
//  PhoneNumberViewController.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PhoneNumberViewController: UIViewController {
    
    static func instantiate() -> PhoneNumberViewController {
        return R.storyboard.phoneNumber.phoneNumberViewController()!
    }

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var phoneNumberField: UITextField!
    @IBOutlet private weak var sendSMSButton: UIButton!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let vm = PhoneNumberViewModel(dependency: .init(
            userUseCase: DomainAssembly.injectUserUseCase()
        ))
        
        let output = vm.transform(input: .init(
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
        
        backButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

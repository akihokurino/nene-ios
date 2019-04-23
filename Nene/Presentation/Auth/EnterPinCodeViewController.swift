//
//  EnterPinCodeViewController.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol EnterPincodeViewControllerDelegate {
    func didEnterPincode(_ pincode: String)
}

final class EnterPincodeViewController: UIViewController {
    
    static func instantiate(delegate: EnterPincodeViewControllerDelegate) -> EnterPincodeViewController {
        let viewController = R.storyboard.enterPinCode.enterPincodeViewController()!
        viewController.delegate = delegate
        return viewController
    }
    
    private var resetTrigger: PublishSubject<Void> = PublishSubject()
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private var codeTextLabels: [UILabel]!
    @IBOutlet private var backgroundViews: [UIView]!
    
    private var delegate: EnterPincodeViewControllerDelegate!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    
    private func bind() {
        NotificationCenter.default.rx
            .notification(Notification.Name.NSExtensionHostWillEnterForeground)
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.textField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        let vm = EnterPincodeViewModel(dependency: .init())
        
        let output = vm.transform(input: .init(
            codeText: textField.rx.text.orEmpty.asDriver(),
            resetCodeTrigger: resetTrigger.asDriver(onErrorDriveWith: .empty())
        ))
        
        output.codeText
            .drive(textField.rx.text)
            .disposed(by: disposeBag)
        
        output.code
            .drive(onNext: { [weak self] code in
                self?.updateCodeTextLabels(with: code)
            })
            .disposed(by: disposeBag)
        
        output.pincode
            .drive(onNext: { [weak self] pincode in
                self?.delegate.didEnterPincode(pincode)
            })
            .disposed(by: disposeBag)
    }
        
    private func updateCodeTextLabels(with code: EnterPincodeViewModel.Code) {
        codeTextLabels.enumerated().forEach { index, label in
            switch index {
            case 0:
                label.text = code.firstText
            case 1:
                label.text = code.secondText
            case 2:
                label.text = code.thirdText
            case 3:
                label.text = code.forthText
            case 4:
                label.text = code.fifthText
            case 5:
                label.text = code.sixthText
            default:
                break
            }
        }
    }
}

extension EnterPincodeViewController {
    func reset() {
        resetTrigger.onNext(())
    }
}

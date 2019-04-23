//
//  SubscriptionViewController.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SubscriptionViewController: UITableViewController {
    
    static func instantiate() -> SubscriptionViewController {
        return R.storyboard.subscription.subscriptionViewController()!
    }
    
    @IBOutlet private weak var planTitle: UILabel!
    @IBOutlet private weak var numberField: UITextField!
    @IBOutlet private weak var expField: UITextField!
    @IBOutlet private weak var cvcField: UITextField!
    @IBOutlet private weak var subscribeButton: UIButton!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    private var cancelView: SubscriptionCancelView!
    private var isSubscribe: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelView = SubscriptionCancelView.instance(frame: tableView.bounds)
        
        tableView.tableFooterView?.isHidden = true
       
        bind()
    }
    
    private func bind() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        tableView.addGestureRecognizer(tapGestureRecognizer)
        
        let vm = SubscriptionViewModel(dependency: .init(
            userUseCase: DomainAssembly.injectUserUseCase(),
            subscriptionUseCase: DomainAssembly.injectSubscriptionUseCase()
        ))
        
        let output = vm.transform(input: .init(
            didInputNumber: numberField.rx.text.orEmpty.asDriver(),
            didInputExp: expField.rx.text.orEmpty.asDriver(),
            didInputCvc: cvcField.rx.text.orEmpty.asDriver(),
            didTapSubscribeButton: subscribeButton.rx.tap.asDriver().do(onNext: { [weak self] in
                self?.view.endEditing(true)
            }),
            didTapCancelButton: cancelView.rx.didTapCancelBtn
        ))
        
        output.subscriptionState
            .do(onNext: { [weak self] in
                self?.isSubscribe = $0.isSubscribe
            })
            .drive(onNext: { [weak self] state in
                self?.cancelView.removeFromSuperview()
                
                if state.isSubscribe, let cancelView = self?.cancelView {
                    self?.view.addSubview(cancelView)
                    self?.tableView.tableFooterView?.isHidden = true
                } else {
                    self?.tableView.tableFooterView?.isHidden = false
                }
                
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.subscriptions
            .filter { !$0.isEmpty }
            .drive(onNext: { [weak self] items in
                self?.cancelView?.apply(input: items.first!)
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
        
        let expiryDatePicker = YearMonthPickerView()
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolbar.barStyle = .black
        toolbar.isTranslucent = true
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: nil)
        doneItem.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.expField.resignFirstResponder()
                self?.expField.text = expiryDatePicker.current.toExpireDate()
                self?.expField.sendActions(for: .valueChanged)
            })
            .disposed(by: disposeBag)
        doneItem.tintColor = UIColor.white
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: nil)
        cancelItem.tintColor = UIColor.white

        cancelItem.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.expField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        toolbar.setItems([cancelItem, spaceButton, doneItem], animated: true)
       
        expField.inputView = expiryDatePicker
        expField.inputAccessoryView = toolbar
        
        expiryDatePicker.rx.didSelected
            .drive(onNext: { [weak self] yearMonth in
                self?.expField.text = yearMonth.toExpireDate()
                self?.expField.sendActions(for: .valueChanged)
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func createSectionView(index: Int) -> (UIView, CGFloat) {
        let titleSection: (String) -> (UIView, CGFloat) = { title -> (UIView, CGFloat) in
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
            view.backgroundColor = UIColor.background
            let label = UILabel(frame: CGRect(x: 16, y: 24, width: 200, height: 12))
            label.font = UIFont.normal(size: 12)
            label.textColor = UIColor.white
            label.text = title
            view.addSubview(label)
            return (view, 44)
        }
        
        switch index {
        case 0:
            return titleSection("プラン")
        case 1:
            return titleSection("自動更新")
        case 2:
            return titleSection("支払い情報")
        default:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
            view.backgroundColor = UIColor.background
            return (view, 20)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createSectionView(index: section).0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return createSectionView(index: section).1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isSubscribe ? 0 : 3
    }
}

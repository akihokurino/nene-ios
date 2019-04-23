//
//  ChatRoomViewController.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatRoomViewController: UIViewController {
    
    static func instantiate() -> ChatRoomViewController {
        return R.storyboard.chatRoom.chatRoomViewController()!
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var closeButton: UIBarButtonItem!
    @IBOutlet private weak var messageInputView: MessageInputView!
    @IBOutlet private weak var messageInputHeight: NSLayoutConstraint!
    @IBOutlet private weak var messageInputMarginBottom: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    private var messageInputAnimator: MessageInputAnimator!
    private var messageTableAnimator: MessageTableAnimator!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        tableView.contentInset = UIEdgeInsets(top: MessageInputView.heightWithSafeArea, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 48
        tableView.rowHeight = UITableView.automaticDimension
        
        messageInputView.setup(delegate: self)
        
        bind()
    }
    
    private func bind() {
        let dataSource = DataSource()
        tableView.dataSource = dataSource
        
        messageInputAnimator = MessageInputAnimator(inputView: messageInputView, delegate: self)
        messageTableAnimator = MessageTableAnimator(tableView: tableView)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.messageInputView.hideKeyboard()
            })
            .disposed(by: disposeBag)
        tableView.addGestureRecognizer(tapGestureRecognizer)
        
        closeButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        rx.viewWillAppear.asDriver()
            .drive(onNext: { [weak self] in
                self?.messageInputAnimator.setup()
                self?.messageTableAnimator.setup()
            })
            .disposed(by: disposeBag)
        
        rx.viewWillDisappear.asDriver()
            .drive(onNext: { [weak self] in
                self?.messageInputAnimator.reset()
                self?.messageTableAnimator.reset()
            })
            .disposed(by: disposeBag)
        
        let vm = ChatRoomViewModel(
            dependency: .init(
                userUseCase: DomainAssembly.injectUserUseCase(),
                chatRoomUseCase: DomainAssembly.injectChatRoomUseCase(),
                subscriptionUseCase: DomainAssembly.injectSubscriptionUseCase()
            )
        )
        
        let output = vm.transform(input: .init(
            didInputText: messageInputView.rx.text,
            didTapSendButton: messageInputView.rx.didTapSendBtn,
            reachedBottom: tableView.rx.reachedBottom.asDriver(),
            viewWillAppear: rx.viewWillAppear.asDriver()
        ))
        
        output.messages.drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.didSendMessage
            .drive(onNext: { [weak self] _ in
                self?.messageInputView.hideKeyboard()
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] in
                if AppError.isExpireFreePlan($0) {
                    self?.showExpireFreePlanAlert()
                } else {
                    self?.showAlert(with: $0)
                }
            })
            .disposed(by: disposeBag)
        
        output.initLoading
            .drive(rx.isHUDAnimating)
            .disposed(by: disposeBag)
        
        output.checkEnable
            .filter { !$0 }
            .drive(onNext: { [weak self] enable in
                self?.showExpireFreePlanAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func showExpireFreePlanAlert() {
        let alertViewController = AlertControllerBuilder
            .makeBuilder(
                title: "フリートライアルが終了しています。",
                message: "引き続きneneをご利用する場合は、サブスクリプションをご契約ください。",
                preferedStyle: .alert
            )
            .addAction(title: "閉じる", style: .default, handler: { _ in
                
            })
            .addAction(title: "契約する", style: .default, handler: { [weak self] _ in
                let vc = SubscriptionViewController.instantiate()
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .build()
        present(alertViewController, animated: true)
    }
    
    private class DataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
        typealias Element = [Message]
        private var items: Element = []
        
        func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
            guard case .next(let element) = observedEvent else { return }
            self.items = element
            tableView.reloadData()
        }
        
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let item = items[indexPath.row]
            
            if item.isMine {
                let cell = tableView.dequeueReusableCell(withIdentifier: MyMessageCell.identifer, for: indexPath) as! MyMessageCell
                cell.apply(input: item)
                cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: YourMessageCell.identifer, for: indexPath) as! YourMessageCell
                cell.apply(input: item)
                cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
                return cell
            }
        }
    }
}

extension ChatRoomViewController: UITableViewDelegate {

}

extension ChatRoomViewController: MessageInputAnimatorDelegate {
    func onOpen(height: CGFloat, duration: CGFloat) {
        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window!.safeAreaInsets.bottom
        }
        messageInputMarginBottom.constant = height - bottomPadding
        
        UIView.animate(withDuration: TimeInterval(duration), animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    func onClose(duration: CGFloat) {
        messageInputView.reset()
        messageInputMarginBottom.constant = 0
        messageInputHeight.constant = 50
        
        UIView.animate(withDuration: TimeInterval(duration), animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
}

extension ChatRoomViewController: MessageInputViewDelegate {
    func onChangeHeight(height: CGFloat) {
        messageInputHeight.constant = height
    }
}

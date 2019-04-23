//
//  MessageInputView.swift
//  Nene
//
//  Created by akiho on 2019/01/12.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import NextGrowingTextView
import RxSwift
import RxCocoa

protocol MessageInputViewDelegate: class {
    func onChangeHeight(height: CGFloat)
}

final class MessageInputView: UIView {
    
    private static let HEIGHT: CGFloat = 50
    private static let MAX_LINE: Int = 5
    
    static var heightWithSafeArea: CGFloat {
        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window!.safeAreaInsets.bottom
        }
        
        return HEIGHT + bottomPadding
    }
    
    @IBOutlet fileprivate weak var textView: NextGrowingTextView!
    @IBOutlet fileprivate weak var sendBtn: UIButton!
    
    private weak var delegate: MessageInputViewDelegate?
    private var initTextViewHeight: CGFloat = 0
    private var currentTextViewHeight: CGFloat = 0
    fileprivate var didInputText: PublishSubject<String> = PublishSubject()
    
    func setup(delegate: MessageInputViewDelegate) {
        self.delegate = delegate
        
        initTextViewHeight = textView.frame.size.height
        currentTextViewHeight = initTextViewHeight
        textView.inputView?.backgroundColor = UIColor.primary
        
        sendBtn.isEnabled = false
        sendBtn.backgroundColor = UIColor.inactiveColor
        
        textView.maxNumberOfLines = MessageInputView.MAX_LINE + 1
        textView.textView.keyboardAppearance = UIKeyboardAppearance.dark
        textView.textView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        let placeholder = NSAttributedString(
            string: "メッセージを入力",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.inactiveColor,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0),
                NSAttributedString.Key.baselineOffset: 0
            ])
       
        textView.placeholderAttributedText = placeholder
        textView.textView.font = UIFont.systemFont(ofSize: 12)
        textView.maxNumberOfLines = MessageInputView.MAX_LINE
        
        textView.textView.frame = CGRect(
            x: 0,
            y: 5,
            width: textView.frame.width,
            height: textView.frame.height)
        
        textView.delegates.didChangeHeight = { [weak self] height in
            guard let _self = self else { return }
            
            let newHeight = max(height, 27.3)
            
            let diff: CGFloat = newHeight - _self.currentTextViewHeight
            let viewHeight: CGFloat = _self.frame.size.height + diff
            
            _self.frame = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: viewHeight)
            
            _self.textView.frame = CGRect(
                x: _self.textView.frame.origin.x,
                y: _self.textView.frame.origin.y,
                width: _self.textView.frame.width,
                height: newHeight)
            
            _self.textView.textView.frame = CGRect(
                x: 0,
                y: 5,
                width: _self.textView.frame.width,
                height: _self.textView.frame.height)
            
            _self.currentTextViewHeight = newHeight
            
            _self.delegate?.onChangeHeight(height: viewHeight)
        }
        
        textView.textView.delegate = self
    }
    
    private func toggleActiveSendBtn() {
        if textView.textView.text.isEmpty {
            sendBtn.setTitleColor(UIColor.white, for: .normal)
            sendBtn.backgroundColor = UIColor.inactiveColor
            sendBtn.isEnabled = false
        } else {
            sendBtn.setTitleColor(UIColor.white, for: .normal)
            sendBtn.backgroundColor = UIColor.activeColor
            sendBtn.isEnabled = true
        }
    }
    
    func reset() {
        textView.textView.text = ""
        currentTextViewHeight = initTextViewHeight
        
        toggleActiveSendBtn()
        
        frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: MessageInputView.HEIGHT)
        
        textView.frame = CGRect(
            x: textView.frame.origin.x,
            y: textView.frame.origin.y,
            width: textView.frame.size.width,
            height: initTextViewHeight)
    }
    
    func hideKeyboard() {
        let _ = textView.resignFirstResponder()
    }
}

extension MessageInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        didInputText.onNext(textView.text ?? "")
        
        toggleActiveSendBtn()
    }
}

extension Reactive where Base: MessageInputView {
    var didTapSendBtn: Driver<Void> {
        return base.sendBtn.rx.tap.asDriver()
            .do(onNext: {
            
            })
    }
    
    var text: Driver<String> {
        return base.didInputText.asDriver(onErrorDriveWith: .empty())
    }
}

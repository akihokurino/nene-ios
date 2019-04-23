//
//  MessageInputAnimator.swift
//  Nene
//
//  Created by akiho on 2019/01/14.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

protocol MessageInputAnimatorDelegate: class {
    func onOpen(height: CGFloat, duration: CGFloat)
    func onClose(duration: CGFloat)
}

final class MessageInputAnimator {
    private weak var inputView: MessageInputView?
    private weak var delegate: MessageInputAnimatorDelegate?
    private var lockAnimation: Bool = false
    
    init(inputView: MessageInputView, delegate: MessageInputAnimatorDelegate) {
        self.inputView = inputView
        self.delegate = delegate
    }
    
    func setup() {
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(keyboardWillBeShown(notification:)),
                         name: UIResponder.keyboardWillShowNotification,
                         object: nil)
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(keyboardWillBeHidden(notification:)),
                         name: UIResponder.keyboardWillHideNotification,
                         object: nil)
    }
    
    func reset() {
        NotificationCenter
            .default
            .removeObserver(self,
                            name: UIResponder.keyboardWillShowNotification,
                            object: nil)
        NotificationCenter
            .default
            .removeObserver(self,
                            name: UIResponder.keyboardWillHideNotification,
                            object: nil)
    }
    
    @objc private func keyboardWillBeShown(notification: NSNotification) {
        guard !lockAnimation else {
            return
        }
        
        if let userInfo = notification.userInfo {
            if let keyboard = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat {
                let keyBoardRect = keyboard.cgRectValue
                
                delegate?.onOpen(height: keyBoardRect.size.height, duration: duration)
            }
        }
    }
    
    @objc private func keyboardWillBeHidden(notification: NSNotification) {
        guard !lockAnimation else {
            return
        }
        
        if let userInfo = notification.userInfo {
            if let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat {
                delegate?.onClose(duration: duration)
            }
        }
    }
    
    private func hideKeyboard() {
        inputView?.hideKeyboard()
    }
    
    private func lock() {
        lockAnimation = true
    }
    
    private func unLock() {
        lockAnimation = false
    }
}

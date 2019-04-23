//
//  MessageTableAnimator.swift
//  Nene
//
//  Created by akiho on 2019/01/14.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MessageTableAnimator {
    
    private var lockAnimation: Bool = false
    private weak var tableView: UITableView?
    
    init(tableView: UITableView) {
        self.tableView = tableView
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
                         name:UIResponder.keyboardWillHideNotification,
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
    
    @objc func keyboardWillBeShown(notification: NSNotification) {
        guard !lockAnimation else {
            return
        }
        
        if let userInfo = notification.userInfo{
            if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
                let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                self.restoreScrollViewSize()
                
                let convertedKeyboardFrame = tableView?.superview?.convert(keyboardFrame, to: nil)
                
                self.updateScrollViewSize(moveSize: convertedKeyboardFrame!.size.height, duration: animationDuration)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        guard !lockAnimation else {
            return
        }
        
        restoreScrollViewSize()
    }
    
    private func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        let contentInsets = UIEdgeInsets(top: moveSize, left: 0, bottom: 0, right: 0)
        
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(duration)
        
        tableView?.contentInset = contentInsets
        tableView?.scrollIndicatorInsets = contentInsets
        
        let top = tableView?.contentInset.top ?? 0
        tableView?.contentOffset = CGPoint(x: 0, y: -top)
        
        UIView.commitAnimations()
    }
    
    private func restoreScrollViewSize() {
        tableView?.contentInset = UIEdgeInsets.init(top: MessageInputView.heightWithSafeArea, left: 0, bottom: 0, right: 0)
        tableView?.scrollIndicatorInsets = UIEdgeInsets.init(top: MessageInputView.heightWithSafeArea, left: 0, bottom: 0, right: 0)
    }
    
    func lock() {
        lockAnimation = true
    }
    
    func unLock() {
        lockAnimation = false
    }
}


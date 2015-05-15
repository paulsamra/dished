//
//  DAKeyboardManager.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

protocol DAKeyboardManagerDelegate: class {
    func keyboardWillMoveToFrame(frame: CGRect)
    func keyboardWillHide()
}

class DAKeyboardManager {
    
    weak var delegate: DAKeyboardManagerDelegate?
    
    init(delegate: DAKeyboardManagerDelegate) {
        self.delegate = delegate
    }
    
    func beginObservingKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func endObservingKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            if let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                delegate?.keyboardWillMoveToFrame(value.CGRectValue())
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        delegate?.keyboardWillHide()
    }
}
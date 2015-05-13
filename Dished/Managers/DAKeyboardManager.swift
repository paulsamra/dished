//
//  DAKeyboardManager.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DAKeyboardManager {
    
    func beginObservingKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func endObservingKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillMoveToFrame(frame: CGRect) {

    }
    
    func keyboardWillHide() {
        
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            if let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                keyboardWillMoveToFrame(value.CGRectValue())
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardWillHide()
    }
}
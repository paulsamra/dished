//
//  DALoginKeyboardManager'.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoginKeyboardManager {
   
    var loginView: DALoginView!
    
    init(loginView: DALoginView) {
        self.loginView = loginView
    }
    
    func beginObservingKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func endObservingKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardDidShowToFrame(frame: CGRect) {
        if frame.origin.y > loginView.frame.size.height {
            return
        }
        
        loginView.updateSignInButtonToHeight(frame.origin.y)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            if let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                keyboardDidShowToFrame(value.CGRectValue())
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        loginView.resetSignInButtonBottomConstraint()
    }
}
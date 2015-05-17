//
//  DALoginViewInteractor.swift
//  Dished
//
//  Created by Ryan Khalili on 5/15/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DALoginViewInteractor: NSObject, UITextFieldDelegate {
    
    var loginView: DALoginView!
    
    init(loginView: DALoginView) {
        super.init()
        
        self.loginView = loginView
        loginView.usernameField.delegate = self
        loginView.passwordField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldChangedNotification:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateSignInButtonState() {
        let validUsername = !loginView.usernameField.text.isEmpty
        let validPassword = !loginView.passwordField.text.isEmpty
        let enabled = validUsername && validPassword
        
        loginView.signInButton.enabled = enabled
        loginView.signInButton.alpha = enabled ? 1.0 : 0.4
    }
    
    func textFieldChangedNotification(notification: NSNotification) {
        let textField = notification.object as? UITextField
        
        if textField == loginView.usernameField || textField == loginView.passwordField {
            updateSignInButtonState()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == loginView.usernameField {
            loginView.passwordField.becomeFirstResponder()
        }
        else if textField == loginView.passwordField {
            loginView.delegate?.loginViewDidPressSignInButton(loginView)
        }
        
        return true
    }
}
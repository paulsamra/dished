//
//  DALoginViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoginViewController2: DAViewController, DALoginViewDelegate {

    let loginView = DALoginView()
    var keyboardManager: DALoginKeyboardManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Sign In"
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        loginView.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager.beginObservingKeyboard()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardManager.endObservingKeyboard()
    }
    
    func loginViewDidPressSignInButton(loginView: DALoginView) {
        
    }
    
    func loginViewDidPressRegisterButton(loginView: DALoginView) {
        
    }
    
    func loginViewDidPressFacebookButton(loginView: DALoginView) {
        
    }
    
    func loginViewDidPressForgotPasswordButton(loginView: DALoginView) {
        
    }
    
    override func loadView() {
        loginView.delegate = self
        view = loginView
        keyboardManager = DALoginKeyboardManager(loginView: loginView)
    }
}
//
//  DALoginViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoginViewController2: UIViewController {

    var loginView: DALoginView!
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
    
    override func loadView() {
        loginView = DALoginView()
        view = loginView
        keyboardManager = DALoginKeyboardManager(loginView: loginView)
    }
}
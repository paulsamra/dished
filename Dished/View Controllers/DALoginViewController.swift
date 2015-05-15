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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Sign In"
    }
    
    func loginViewDidPressSignInButton(loginView: DALoginView) {
        
    }
    
    func loginViewDidPressRegisterButton(loginView: DALoginView) {
        let registerPhoneNumberViewController = DARegisterPhoneNumberViewController()
        navigationController?.pushViewController(registerPhoneNumberViewController, animated: true)
    }
    
    func loginViewDidPressFacebookButton(loginView: DALoginView) {
        
    }
    
    func loginViewDidPressForgotPasswordButton(loginView: DALoginView) {
        let verifyPhoneNumberViewController = DAVerifyPhoneNumberViewController()
        navigationController?.pushViewController(verifyPhoneNumberViewController, animated: true)
    }
    
    override func loadView() {
        loginView.delegate = self
        view = loginView
    }
}
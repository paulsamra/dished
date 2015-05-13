//
//  DAVerifyPhoneNumberViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAVerifyPhoneNumberViewController: DAPhoneNumberViewController2 {
    
    private let message = "Enter the phone number you signed up with, and Dished will text you a verification code, which you will use to reset your password."
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func phoneNumberViewDidPressSubmitButton(phoneNumberView: DAPhoneNumberView) {
        
    }
    
    override func loadView() {
        super.loadView()
        phoneNumberView.messageLabel.text = message
    }
}
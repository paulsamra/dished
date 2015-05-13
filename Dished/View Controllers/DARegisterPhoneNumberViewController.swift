//
//  DARegisterPhoneNumberViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DARegisterPhoneNumberViewController: DAPhoneNumberViewController2 {

    private let message = "To sign up for Dished, you will need to verify your phone number and device. We will only use your phone number if you need to reset your password."
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        phoneNumberView.messageLabel.text = message
    }
}
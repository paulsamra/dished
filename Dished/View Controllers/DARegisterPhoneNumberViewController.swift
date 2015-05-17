//
//  DARegisterPhoneNumberViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DARegisterPhoneNumberViewController: DAPhoneNumberViewController2 {

    private var facebookUser: NSDictionary?
    
    private let message = "To sign up for Dished, you will need to verify your phone number and device. We will only use your phone number if you need to reset your password."
    
    init() {
        facebookUser = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(facebookUser: NSDictionary) {
        self.facebookUser = facebookUser
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        facebookUser = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func phoneNumberViewDidPressSubmitButton(phoneNumberView: DAPhoneNumberView) {
        super.phoneNumberViewDidPressSubmitButton(phoneNumberView)
        
        let phoneNumber = interactor.phoneNumberFromString(phoneNumberView.phoneNumberField.text)
        
    }
    
    override func loadView() {
        super.loadView()
        phoneNumberView.messageLabel.text = message
        
        navigationItem.title = "Enter Phone Number"
    }
}
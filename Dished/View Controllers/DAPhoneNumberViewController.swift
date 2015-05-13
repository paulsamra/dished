//
//  DAPhoneNumberViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAPhoneNumberViewController2: DAViewController, DAPhoneNumberViewDelegate {

    var phoneNumberView = DAPhoneNumberView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func phoneNumberViewDidPressSubmitButton(phoneNumberView: DAPhoneNumberView) {
        
    }
    
    override func loadView() {
        phoneNumberView.delegate = self
        view = phoneNumberView
    }
}
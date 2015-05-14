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
    var keyboardManager: DAPhoneKeyboardManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardManager = DAPhoneKeyboardManager(view: phoneNumberView)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        phoneNumberView.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager.beginObservingKeyboard()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardManager.endObservingKeyboard()
    }
    
    func phoneNumberViewDidPressSubmitButton(phoneNumberView: DAPhoneNumberView) {
        
    }
    
    override func loadView() {
        phoneNumberView.delegate = self
        view = phoneNumberView
    }
}
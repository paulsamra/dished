//
//  DAPhoneNumberViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAPhoneNumberViewController2: DALoggedOutViewController, DAPhoneNumberViewDelegate {

    var phoneNumberView = DAPhoneNumberView()
    var interactor: DAPhoneNumberViewInteractor!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactor = DAPhoneNumberViewInteractor(phoneNumberView: phoneNumberView)
        interactor.setSubmitButtonEnabled(false)
    }
    
    func phoneNumberViewDidPressSubmitButton(phoneNumberView: DAPhoneNumberView) {
        phoneNumberView.endEditing(true)
        navigationController?.showOverlayWithTitle("")
    }
    
    override func loadView() {
        phoneNumberView.delegate = self
        view = phoneNumberView
    }
}
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
        sendVerificationCode()
    }
    
    func sendVerificationCode() {
        
    }
    
    func failedToSendVerificationCode() {
        navigationController?.hideOverlayWithCompletion({
            self.showAlertWithTitle("Request Error", message: "There was an error requesting a verification code. Please make sure you entered a valid phone number.")
        })
    }
    
    override func loadView() {
        phoneNumberView.delegate = self
        view = phoneNumberView
    }
}
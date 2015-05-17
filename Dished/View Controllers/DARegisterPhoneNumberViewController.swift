//
//  DARegisterPhoneNumberViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DARegisterPhoneNumberViewController: DAPhoneNumberViewController2, UIAlertViewDelegate {

    lazy var sentCodeAlert: UIAlertView = {
        let alertView = UIAlertView(title: "Enter Verification Code", message: "You will receive a text message with a six-digit verification code.", delegate: self, cancelButtonTitle: "Cancel")
        
        alertView.addButtonWithTitle("OK")
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alertView.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.DecimalPad
    
        return alertView
    }()
    
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
    
    override func sendVerificationCode() {
        let phoneNumber = interactor.phoneNumberFromString(phoneNumberView.phoneNumberField.text)
        let parameters = [kPhoneKey : phoneNumber]
        
        DAAPIManager.sharedManager().POST(kAuthPhoneVerifyURL, parameters: parameters, success: {
            task, response in
            self.finishedSendingVerificationCode()
        },
        failure: {
            task, error in
            self.failedToSendVerificationCode()
        })
    }
    
    private func finishedSendingVerificationCode() {
        sentCodeAlert.textFieldAtIndex(0)?.text = ""
        sentCodeAlert.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView == sentCodeAlert && buttonIndex != alertView.cancelButtonIndex {
            if let verificationCode = alertView.textFieldAtIndex(0)?.text {
                verifyVerificationCode(verificationCode)
            }
        }
    }
    
    private func verifyVerificationCode(verificationCode: String) {
        let phoneNumber = interactor.phoneNumberFromString(phoneNumberView.phoneNumberField.text)
        let parameters = [kPhoneKey: phoneNumber, "pin": verificationCode]
        
        DAAPIManager.sharedManager().POST(kAuthPhoneVerifyURL, parameters: parameters, success: {
            task, response in
            self.finishedVerifyingVerificationCode()
        },
        failure: {
            task, error in
            self.failedToVerifyVerificationCode()
        })
    }
    
    private func finishedVerifyingVerificationCode() {
        navigationController?.hideOverlayWithCompletion({
            if self.facebookUser != nil {
                self.navigator.navigateToRegistrationFormWithFacebookUser(self.facebookUser!)
            }
            else {
                self.navigator.navigateToRegistrationForm()
            }
        })
    }
    
    private func failedToVerifyVerificationCode() {
        navigationController?.hideOverlayWithCompletion({
            self.showAlertWithTitle("Incorrect Code", message: "The verification code was incorrect. Please try again.")
        })
    }
    
    override func loadView() {
        super.loadView()
        phoneNumberView.messageLabel.text = message
        
        navigationItem.title = "Enter Phone Number"
    }
}
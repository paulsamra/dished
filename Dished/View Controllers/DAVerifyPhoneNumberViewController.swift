//
//  DAVerifyPhoneNumberViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAVerifyPhoneNumberViewController: DAPhoneNumberViewController2, UIAlertViewDelegate {
    
    private var sentCodeAlert: UIAlertView?
    private let message = "Enter the phone number you signed up with, and Dished will text you a verification code, which you will use to reset your password."
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func phoneNumberViewDidPressSubmitButton(phoneNumberView: DAPhoneNumberView) {
        super.phoneNumberViewDidPressSubmitButton(phoneNumberView)
        
        let phoneNumber = interactor.currentlyEnteredPhoneNumber()
        
        DAAPIManager.sharedManager().requestPasswordResetCodeWithPhoneNumber(phoneNumber, completion: {
            success in
            self.passwordResetRequestFinishedWithSuccess(success)
        })
    }
    
    private func passwordResetRequestFinishedWithSuccess(success: Bool) {
        navigationController?.hideOverlayWithCompletion({
            success ? self.sentPasswordResetCode() : self.failedToSendPasswordResetCode()
        })
    }
    
    func failedToSendPasswordResetCode() {
        showAlertWithTitle("Request Error", message: "There was an error requesting a verification code. Please make sure you entered a valid phone number.")
    }
    
    func sentPasswordResetCode() {
        sentCodeAlert = UIAlertView(title: "Verification Code Sent", message: "You will receive a text message with your verification code. Enter it on the next screen, along with your new password.", delegate: self, cancelButtonTitle: "Cancel")
        sentCodeAlert!.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView == sentCodeAlert {
           goToResetPasswordView()
        }
    }
    
    func goToResetPasswordView() {
        let phoneNumber = interactor.currentlyEnteredPhoneNumber()
        navigator.navigateToResetPasswordViewWithPhoneNumber(phoneNumber)
    }
    
    override func loadView() {
        super.loadView()
        phoneNumberView.messageLabel.text = message
        
        navigationItem.title = "Forgot Password"
    }
}
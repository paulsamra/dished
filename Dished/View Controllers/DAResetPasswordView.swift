//
//  DAResetPasswordView.swift
//  Dished
//
//  Created by Ryan Khalili on 5/14/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAResetPasswordView: DAKeyboardRespondableView {
    
    var submitButton: UIButton!
    var passwordField: UITextField!
    var confirmPasswordField: UITextField!
    var verificationCodeField: UITextField!
    
    private var bottomConstraint: NSLayoutConstraint!
    
    override func keyboardWillMoveToFrame(frame: CGRect) {
        
    }
    
    override func keyboardWillHide() {
        
    }
    
    private func updateViewToHeight(height: CGFloat) {
        
    }
    
    private func resetViewHeight() {
        
    }
    
    override func setupViews() {
        backgroundColor = UIColor(r: 249, g: 249, b: 249, a: 255)
        
        var verifyFieldBackground = UIImageView(image: UIImage(named: "reset_code"))
        verifyFieldBackground.userInteractionEnabled = true
        addSubview(verifyFieldBackground)
        verifyFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        verifyFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        verifyFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 116.0)
        
        verificationCodeField = UITextField()
        verificationCodeField.placeholder = "Verification Code"
        verificationCodeField.font = DAConstants.primaryFontWithSize(18.0)
        constrainTextField(verificationCodeField, toBackgroundView: verifyFieldBackground)
        
        var passwordFieldBackground = UIImageView(image: UIImage(named: "reset_password"))
        passwordFieldBackground.userInteractionEnabled = true
        addSubview(passwordFieldBackground)
        passwordFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        passwordFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        passwordFieldBackground.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: verifyFieldBackground, withOffset: 60.0)
        
        passwordField = UITextField()
        passwordField.placeholder = "New Password"
        passwordField.font = DAConstants.primaryFontWithSize(18.0)
        constrainTextField(passwordField, toBackgroundView: passwordFieldBackground)
        
        var confirmFieldBackground = UIImageView(image: UIImage(named: "reset_password_confirm"))
        confirmFieldBackground.userInteractionEnabled = true
        addSubview(confirmFieldBackground)
        confirmFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        confirmFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        confirmFieldBackground.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: passwordFieldBackground)
        
        confirmPasswordField = UITextField()
        confirmPasswordField.placeholder = "Confirm Password"
        confirmPasswordField.font = DAConstants.primaryFontWithSize(18.0)
        constrainTextField(confirmPasswordField, toBackgroundView: confirmFieldBackground)
        
        submitButton = UIButton()
        submitButton.titleLabel?.font = DAConstants.primaryFontWithSize(22.0)
        submitButton.setBackgroundImage(UIImage(named: "reset_submit"), forState: UIControlState.Normal)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.setTitleColor(UIColor.dishedColor(), forState: UIControlState.Normal)
        submitButton.addTarget(self, action: "submitButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(submitButton)
        submitButton.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        submitButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        bottomConstraint = submitButton.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: confirmFieldBackground)
    }
    
    private func constrainTextField(textField: UITextField, toBackgroundView background: UIImageView) {
        background.addSubview(textField)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 20.0)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 20.0)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 7)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 7)
    }
}
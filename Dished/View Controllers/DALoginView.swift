//
//  DALoginView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

protocol DALoginViewDelegate: class {
    func loginViewDidPressSignInButton(loginView: DALoginView)
    func loginViewDidPressFacebookButton(loginView: DALoginView)
    func loginViewDidPressRegisterButton(loginView: DALoginView)
    func loginViewDidPressForgotPasswordButton(loginView: DALoginView)
}

class DALoginView: DAKeyboardRespondableView {
    
    var usernameField: UITextField!
    var passwordField: UITextField!
    var signInButton: UIButton!
    var facebookButton: UIButton!
    var registerButton: UIButton!
    var forgotPasswordButton: UIButton!
    var orLabel: UILabel!
    
    weak var delegate: DALoginViewDelegate?
    
    var signInButtonBottomConstraint: NSLayoutConstraint!
    
    override func keyboardWillMoveToFrame(frame: CGRect) {
        if frame.origin.y > self.frame.size.height {
            return
        }
        
        updateSignInButtonToHeight(frame.origin.y)
    }
    
    override func keyboardWillHide() {
         resetSignInButtonBottomConstraint()
    }
    
    private func updateSignInButtonToHeight(height: CGFloat) {
        let bottomSignInY = signInButton.frame.origin.y + signInButton.frame.size.height
        
        if height >= bottomSignInY {
            return
        }
        
        let difference = height - bottomSignInY
        
        signInButtonBottomConstraint.constant -= -difference
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    private func resetSignInButtonBottomConstraint() {
        signInButtonBottomConstraint.constant = -13.0
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    func registerButtonPressed() {
        delegate?.loginViewDidPressRegisterButton(self)
    }
    
    func signInButtonPressed() {
        delegate?.loginViewDidPressSignInButton(self)
    }
    
    func facebookButtonPressed() {
        delegate?.loginViewDidPressFacebookButton(self)
    }
    
    func forgotPasswordButtonPressed() {
        delegate?.loginViewDidPressForgotPasswordButton(self)
    }
    
    override func setupViews() {
        let grayValue = CGFloat( 249.0 / 255.0 )
        backgroundColor = UIColor(red: grayValue, green: grayValue, blue: grayValue, alpha: 1.0)
        
        let blueTextColor = UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 1.0)
        
        let noAccountLabel = UILabel()
        noAccountLabel.text = "Don't have an account?"
        noAccountLabel.textColor = blueTextColor
        noAccountLabel.font = DAConstants.primaryFontWithSize(17.0)
        noAccountLabel.sizeToFit()
        addSubview(noAccountLabel)
        noAccountLabel.autoSetDimensionsToSize(noAccountLabel.frame.size)
        noAccountLabel.autoAlignAxis(ALAxis.Vertical, toSameAxisOfView: self, withOffset: -47.0)
        noAccountLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 11.0)
        
        registerButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        registerButton.setTitle("Register", forState: UIControlState.Normal)
        registerButton.titleLabel?.font = DAConstants.primaryFontWithSize(17.0)
        registerButton.setTitleColor(blueTextColor, forState: UIControlState.Normal)
        registerButton.addTarget(self, action: "registerButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        registerButton.sizeToFit()
        addSubview(registerButton)
        registerButton.autoSetDimensionsToSize(registerButton.bounds.size)
        registerButton.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: noAccountLabel)
        registerButton.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: noAccountLabel, withOffset: 15.0)
        
        forgotPasswordButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        forgotPasswordButton.setTitle("Forgot Your Password?", forState: UIControlState.Normal)
        forgotPasswordButton.titleLabel?.font = DAConstants.primaryFontWithSize(17.0)
        forgotPasswordButton.setTitleColor(blueTextColor, forState: UIControlState.Normal)
        forgotPasswordButton.addTarget(self, action: "forgotPasswordButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        forgotPasswordButton.sizeToFit()
        addSubview(forgotPasswordButton)
        forgotPasswordButton.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        forgotPasswordButton.autoSetDimensionsToSize(CGSizeMake(forgotPasswordButton.bounds.size.width, 25.0))
        forgotPasswordButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: noAccountLabel, withOffset: -12.0)
        
        facebookButton = DAFacebookConnectButton()
        facebookButton.addTarget(self, action: "facebookButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(facebookButton)
        facebookButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: forgotPasswordButton, withOffset: -12.0)
        facebookButton.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        facebookButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        facebookButton.autoSetDimension(ALDimension.Height, toSize: 53.0)
        
        orLabel = UILabel()
        orLabel.font = UIFont.systemFontOfSize(18.0)
        orLabel.textColor = UIColor.darkGrayColor()
        orLabel.text = "OR"
        orLabel.sizeToFit()
        addSubview(orLabel)
        orLabel.autoSetDimensionsToSize(orLabel.bounds.size)
        orLabel.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: facebookButton, withOffset: -11.0)
        orLabel.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        
        signInButton = UIButton()
        signInButton.setTitle("Sign In", forState: UIControlState.Normal)
        signInButton.titleLabel?.font = DAConstants.primaryFontWithSize(22.0)
        signInButton.setBackgroundImage(UIImage(named: "login"), forState: UIControlState.Normal)
        signInButton.setTitleColor(blueTextColor, forState: UIControlState.Normal)
        signInButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        signInButton.addTarget(self, action: "signInButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(signInButton)
        signInButtonBottomConstraint = signInButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: orLabel, withOffset: -13.0)
        signInButton.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        signInButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        signInButton.autoSetDimension(ALDimension.Height, toSize: 54.0)
        
        let passwordBackground = UIImageView()
        passwordBackground.image = UIImage(named: "password")
        passwordBackground.userInteractionEnabled = true
        addSubview(passwordBackground)
        passwordBackground.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: signInButton)
        passwordBackground.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        passwordBackground.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        passwordBackground.autoSetDimension(ALDimension.Height, toSize: 44.0)
        
        let usernameBackground = UIImageView()
        usernameBackground.image = UIImage(named: "username")
        usernameBackground.userInteractionEnabled = true
        addSubview(usernameBackground)
        usernameBackground.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: passwordBackground)
        usernameBackground.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        usernameBackground.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        usernameBackground.autoSetDimension(ALDimension.Height, toSize: 44.0)
        
        usernameField = UITextField()
        usernameField.placeholder = "Username or Email"
        usernameField.font = DAConstants.primaryFontWithSize(18.0)
        usernameField.returnKeyType = UIReturnKeyType.Next
        usernameField.autocorrectionType = UITextAutocorrectionType.No
        constrainTextField(usernameField, toBackgroundView: usernameBackground)
        
        passwordField = UITextField()
        passwordField.placeholder = "Password"
        passwordField.font = DAConstants.primaryFontWithSize(18.0)
        passwordField.returnKeyType = UIReturnKeyType.Go
        passwordField.secureTextEntry = true
        passwordField.clearButtonMode = UITextFieldViewMode.WhileEditing
        constrainTextField(passwordField, toBackgroundView: passwordBackground)
    }

    private func constrainTextField(textField: UITextField, toBackgroundView background: UIImageView) {
        background.addSubview(textField)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 20.0)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 20.0)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 7)
        textField.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 7)
    }
}
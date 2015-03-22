//
//  DALoginView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoginView: DAView {
    
    var usernameField: UITextField!
    var passwordField: UITextField!
    var signInButton: UIButton!
    var facebookButton: UIButton!
    var registerButton: UIButton!
    var forgotPasswordButton: UIButton!
    
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
        
        registerButton = UIButton()
        registerButton.setTitle("Register", forState: UIControlState.Normal)
        registerButton.titleLabel?.font = DAConstants.primaryFontWithSize(17.0)
        registerButton.setTitleColor(blueTextColor, forState: UIControlState.Normal)
        registerButton.sizeToFit()
        addSubview(registerButton)
        registerButton.autoSetDimensionsToSize(registerButton.bounds.size)
        registerButton.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: noAccountLabel)
        registerButton.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: noAccountLabel, withOffset: 15.0)
        
        forgotPasswordButton = UIButton()
        forgotPasswordButton.setTitle("Forgot Your Password?", forState: UIControlState.Normal)
        forgotPasswordButton.titleLabel?.font = DAConstants.primaryFontWithSize(17.0)
        forgotPasswordButton.setTitleColor(blueTextColor, forState: UIControlState.Normal)
        forgotPasswordButton.sizeToFit()
        addSubview(forgotPasswordButton)
        forgotPasswordButton.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        forgotPasswordButton.autoSetDimensionsToSize(CGSizeMake(forgotPasswordButton.bounds.size.width, 25.0))
        forgotPasswordButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: noAccountLabel, withOffset: -12.0)
        
        facebookButton = DAFacebookConnectButton()
        addSubview(facebookButton)
        facebookButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: forgotPasswordButton, withOffset: -12.0)
        facebookButton.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        facebookButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        facebookButton.autoSetDimension(ALDimension.Height, toSize: 53.0)
        
        let orLabel = UILabel()
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
        addSubview(signInButton)
        signInButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: orLabel, withOffset: -13.0)
        signInButton.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        signInButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        signInButton.autoSetDimension(ALDimension.Height, toSize: 53.0)
        
        let passwordBackground = UIImageView()
        passwordBackground.image = UIImage(named: "password")
        addSubview(passwordBackground)
        passwordBackground.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: signInButton)
        passwordBackground.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        passwordBackground.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        passwordBackground.autoSetDimension(ALDimension.Height, toSize: 53.0)
        
        let usernameBackground = UIImageView()
        usernameBackground.image = UIImage(named: "username")
        addSubview(usernameBackground)
        usernameBackground.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: passwordBackground)
        usernameBackground.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        usernameBackground.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        usernameBackground.autoSetDimension(ALDimension.Height, toSize: 53.0)
    }
}
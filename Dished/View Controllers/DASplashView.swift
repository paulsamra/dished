//
//  DAInitialView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DASplashView: DAView {
    
    var backgroundImageView: UIImageView!
    var facebookButton: DAFacebookConnectButton!
    var signInButton: UIButton!
    var registerButton: UIButton!
    var welcomeView: DAWelcomeView!
    
    var welcomeViewVisible: Bool {
        get {
            return !welcomeView.hidden
        }
    }
    
    override func setupViews() {
        backgroundImageView = UIImageView()
        backgroundImageView.image = DAConstants.launchImage()
        addSubview(backgroundImageView)
        backgroundImageView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        let grayBackgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
        let blueBackgroundColor = UIColor(red: 0.16, green: 0.45, blue: 0.71, alpha: 1.0)
        let blueTextColor = UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 1.0)
        
        registerButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        registerButton.setBackgroundImage(UIImage.imageWithColor(grayBackgroundColor), forState: UIControlState.Normal)
        registerButton.setTitle("Register", forState: UIControlState.Normal)
        registerButton.titleLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 23.0)
        registerButton.setTitleColor(blueTextColor, forState: UIControlState.Normal)
        registerButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        addSubview(registerButton)
        registerButton.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 40.0)
        registerButton.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        registerButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        registerButton.autoSetDimension(ALDimension.Height, toSize: 53.0)
        
        let orLabel = UILabel()
        orLabel.font = UIFont.systemFontOfSize(18.0)
        orLabel.textColor = UIColor.whiteColor()
        orLabel.text = "OR"
        orLabel.sizeToFit()
        addSubview(orLabel)
        orLabel.autoSetDimensionsToSize(orLabel.bounds.size)
        orLabel.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: registerButton, withOffset: -20.0)
        orLabel.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        
        signInButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        signInButton.setBackgroundImage(UIImage.imageWithColor(grayBackgroundColor), forState: UIControlState.Normal)
        signInButton.setTitle("Sign In", forState: UIControlState.Normal)
        signInButton.titleLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 23.0)
        signInButton.setTitleColor(blueTextColor, forState: UIControlState.Normal)
        signInButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        addSubview(signInButton)
        signInButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: orLabel, withOffset: -20.0)
        signInButton.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        signInButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        signInButton.autoSetDimension(ALDimension.Height, toSize: 53.0)
        
        facebookButton = DAFacebookConnectButton()
        addSubview(facebookButton)
        facebookButton.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: signInButton)
        facebookButton.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 0)
        facebookButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 0)
        facebookButton.autoSetDimension(ALDimension.Height, toSize: 53.0)
        
        welcomeView = DAWelcomeView()
        welcomeView.hidden = true
        addSubview(welcomeView)
        welcomeView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    func showWelcomeView() {
        let options = UIViewAnimationOptions.TransitionCrossDissolve
        UIView.transitionWithView(welcomeView, duration: 0.4, options: options,
        animations: {
            self.welcomeView.hidden = false
        },
        completion: nil)
    }
    
    func hideWelcomeView() {
        let options = UIViewAnimationOptions.TransitionCrossDissolve
        UIView.transitionWithView(welcomeView, duration: 0.4, options: options,
        animations: {
            self.welcomeView.hidden = true
        },
        completion: nil)
    }
}
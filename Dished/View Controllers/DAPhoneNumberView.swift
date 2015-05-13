//
//  DAPhoneNumberView.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

protocol DAPhoneNumberViewDelegate: class {
    func phoneNumberViewDidPressSubmitButton(phoneNumberView: DAPhoneNumberView)
}

class DAPhoneNumberView: DAView {
    
    var messageLabel: UILabel!
    var phoneNumberField: UITextField!
    var submitButton: UIButton!
    
    weak var delegate: DAPhoneNumberViewDelegate?
    
    func submitButtonPressed() {
        delegate?.phoneNumberViewDidPressSubmitButton(self)
    }
    
    override func setupViews() {
        submitButton = UIButton()
        submitButton.titleLabel?.font = DAConstants.primaryFontWithSize(22.0)
        submitButton.setBackgroundImage(UIImage(named: "phone_submit"), forState: UIControlState.Normal)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.setTitleColor(UIColor.dishedColor(), forState: UIControlState.Normal)
        submitButton.addTarget(self, action: "submitButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(submitButton)
        submitButton.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        submitButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        submitButton.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 178.0)
        
        let phoneNumberFieldBackground = UIImageView(image: UIImage(named: "phone_number"))
        phoneNumberFieldBackground.userInteractionEnabled = true
        addSubview(phoneNumberFieldBackground)
        phoneNumberFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        phoneNumberFieldBackground.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        phoneNumberFieldBackground.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: submitButton)
        
        messageLabel = UILabel()
        messageLabel.numberOfLines = 6
        messageLabel.font = DAConstants.primaryFontWithSize(17.0)
        messageLabel.textAlignment = NSTextAlignment.Center
        addSubview(messageLabel)
        messageLabel.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        messageLabel.autoSetDimensionsToSize(CGSizeMake(285.0, 81.0))
        messageLabel.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: phoneNumberFieldBackground, withOffset: -41.0)
        
        phoneNumberField = UITextField()
        phoneNumberField.placeholder = "Phone Number"
        phoneNumberField.font = DAConstants.primaryFontWithSize(18.0)
        phoneNumberFieldBackground.addSubview(phoneNumberField)
        phoneNumberField.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 20.0)
        phoneNumberField.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 20.0)
        phoneNumberField.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 7)
        phoneNumberField.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 7)
    }
}
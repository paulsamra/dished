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

class DAPhoneNumberView: DAKeyboardRespondableView {
    
    var messageLabel: UILabel!
    var phoneNumberField: UITextField!
    var submitButton: UIButton!
    
    private var bottomConstraint: NSLayoutConstraint!
    
    weak var delegate: DAPhoneNumberViewDelegate?
    
    override func keyboardWillMoveToFrame(frame: CGRect) {
        if frame.origin.y > frame.size.height {
            return
        }
        
        updateViewToHeight(frame.size.height)
    }
    
    override func keyboardWillHide() {
        resetViewHeight()
    }
    
    func submitButtonPressed() {
        delegate?.phoneNumberViewDidPressSubmitButton(self)
    }
    
    private func updateViewToHeight(height: CGFloat) {
        let bottomSubmitY = submitButton.frame.origin.y + submitButton.frame.size.height
        
        if height >= bottomSubmitY {
            return
        }
        
        bottomConstraint.constant = -height
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    private func resetViewHeight() {
        bottomConstraint.constant = -178.0
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    override func setupViews() {
        backgroundColor = UIColor(r: 249, g: 249, b: 249, a: 255)

        submitButton = UIButton()
        submitButton.titleLabel?.font = DAConstants.primaryFontWithSize(22.0)
        submitButton.setBackgroundImage(UIImage(named: "phone_submit"), forState: UIControlState.Normal)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.setTitleColor(UIColor.dishedColor(), forState: UIControlState.Normal)
        submitButton.addTarget(self, action: "submitButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(submitButton)
        submitButton.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        submitButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        bottomConstraint = submitButton.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 178.0)
        
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
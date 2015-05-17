//
//  DAPhoneNumberViewInteractor.swift
//  Dished
//
//  Created by Ryan Khalili on 5/17/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DAPhoneNumberViewInteractor: NSObject, UITextFieldDelegate {
    
    var phoneNumberView: DAPhoneNumberView
    
    init(phoneNumberView: DAPhoneNumberView) {
        self.phoneNumberView = phoneNumberView
        super.init()
        phoneNumberView.phoneNumberField.delegate = self
    }
    
    func currentlyEnteredPhoneNumber() -> String {
        return phoneNumberFromString(phoneNumberView.phoneNumberField.text)
    }
    
    func setSubmitButtonEnabled(enabled: Bool) {
        phoneNumberView.submitButton.enabled = enabled;
        phoneNumberView.submitButton.alpha = enabled ? 1 : 0.4;
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text.isEmpty {
            textField.text = "+1 ";
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if count(textField.text) == 3 {
            textField.text = "";
        }
    }
    
    func phoneNumberFromString(string: String) -> String {
        let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let numbers = string.componentsSeparatedByCharactersInSet(characterSet)
        var decimalString = "".join(numbers)

        if decimalString[0] == "1" {
            decimalString = decimalString.substringFromIndex(advance(decimalString.startIndex, 1))
        }
        
        return decimalString
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string) as String
        
        if count(newString) < 3 {
            return false
        }
        
        let decimalString = phoneNumberFromString(newString)
        let length = count(decimalString)
        
        if length > 10 {
            return false
        }
        
        var index = 0
        var formattedString = "+1 "
        
        if length - index > 3 {
            if let areaCode = decimalString[index..index + 3] {
                formattedString += "(\(areaCode)) "
                index += 3
            }
        }
        
        if length - index > 3 {
            if let prefix = decimalString[index..index + 3] {
                formattedString += "\(prefix)-"
                index += 3
            }
        }
        
        let remainder = decimalString.substringFromIndex(advance(decimalString.startIndex, index))
        formattedString += remainder
        
        textField.text = formattedString
        
        if length == 10 {
            setSubmitButtonEnabled(true)
        }
        else {
            setSubmitButtonEnabled(false)
        }
        
        return false
    }
}
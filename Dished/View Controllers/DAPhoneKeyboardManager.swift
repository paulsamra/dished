//
//  DAPhoneKeyboardManager.swift
//  Dished
//
//  Created by Ryan Khalili on 5/14/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAPhoneKeyboardManager: DAKeyboardManager {
    
    var phoneNumberView: DAPhoneNumberView!
    
    init(view: DAPhoneNumberView) {
        phoneNumberView = view
    }
    
    override func keyboardWillMoveToFrame(frame: CGRect) {
        if frame.origin.y > phoneNumberView.frame.size.height {
            return
        }
        
        phoneNumberView.updateViewToHeight(frame.size.height)
    }
    
    override func keyboardWillHide() {
        phoneNumberView.resetViewHeight()
    }
}
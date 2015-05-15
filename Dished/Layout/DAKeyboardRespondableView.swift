//
//  DAKeyboardRespondableView.swift
//  Dished
//
//  Created by Ryan Khalili on 5/14/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAKeyboardRespondableView: DALoadingView, DAKeyboardManagerDelegate {
    
    lazy var keyboardManager: DAKeyboardManager = {
        return DAKeyboardManager(delegate: self)
    }()
    
    func beginObservingKeyboard() {
        keyboardManager.beginObservingKeyboard()
    }
    
    func endObservingKeyboard() {
        keyboardManager.endObservingKeyboard()
    }
    
    func keyboardWillMoveToFrame(frame: CGRect) {
        
    }
    
    func keyboardWillHide() {
        
    }
}
//
//  DALoginKeyboardManager'.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoginKeyboardManager: DAKeyboardManager {
   
    var loginView: DALoginView!
    
    init(loginView: DALoginView) {
        self.loginView = loginView
    }
    
    override func keyboardWillMoveToFrame(frame: CGRect) {
        if frame.origin.y > loginView.frame.size.height {
            return
        }
        
        loginView.updateSignInButtonToHeight(frame.origin.y)
    }
    
    override func keyboardWillHide() {
        loginView.resetSignInButtonBottomConstraint()
    }
}
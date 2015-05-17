//
//  DAResetPasswordViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/14/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAResetPasswordViewController2: DAViewController {

    var resetPasswordView = DAResetPasswordView()
    var phoneNumber: String
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        self.phoneNumber = ""
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = resetPasswordView
    }
}
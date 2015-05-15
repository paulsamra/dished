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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = resetPasswordView
    }
}
//
//  DAFacebookLoginViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFacebookLoginViewController2: DAViewController {

    let facebookLoginView = DAFacebookLoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = facebookLoginView
    }
}
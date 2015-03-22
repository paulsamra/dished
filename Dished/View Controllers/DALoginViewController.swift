//
//  DALoginViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoginViewController2: UIViewController {

    var loginView: DALoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        loginView = DALoginView()
        view = loginView
    }
}
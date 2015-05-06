//
//  DAShareSettingsViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAShareSettingsViewController2: DAViewController {
    
    let shareSettingsView = DAShareSettingsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func loadView() {
        view = shareSettingsView
        
        navigationItem.title = "Share Settings"
    }
}
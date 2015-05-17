//
//  DALoggedOutViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/17/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoggedOutViewController: DAViewController {
    
    lazy var navigator: DALoginNavigator = {
        return DALoginNavigator(navigationController: self.navigationController)
    }()
}
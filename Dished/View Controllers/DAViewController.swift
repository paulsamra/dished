//
//  DAViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackNavigationItem()
    }
    
    private func setupBackNavigationItem() {
        navigationItem.backBarButtonItem = UIBarButtonItem( title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil )
    }
}
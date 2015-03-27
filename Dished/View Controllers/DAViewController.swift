//
//  DAViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAViewController: UIViewController {

    var dataSource: DADataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackNavigationItem()
    }
    
    deinit {
        dataSource?.cancelLoadingData()
    }
    
    private func setupBackNavigationItem() {
        navigationItem.backBarButtonItem = UIBarButtonItem( title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil )
    }
}
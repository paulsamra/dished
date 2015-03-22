//
//  DADishMapViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DADishMapViewController: UIViewController {

    var dishMapView = DADishMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = dishMapView
    }
}
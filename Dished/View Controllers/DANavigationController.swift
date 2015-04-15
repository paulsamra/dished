//
//  DANavigationController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DANavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustAppearance()
    }
    
    private func adjustAppearance() {
        let barFrame = navigationBar.frame
        let hairlineRect = CGRectMake(0, barFrame.size.height, barFrame.size.width, 0.5)
        
        let navBorder = UIView(frame: hairlineRect)
        navBorder.backgroundColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.0)
        navBorder.opaque = true
        navigationBar.addSubview(navBorder)
        
        navigationBar.barTintColor = UIColor.whiteColor()
    }
}
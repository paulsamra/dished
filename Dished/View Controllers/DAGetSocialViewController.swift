//
//  DAGetSocialViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAGetSocialViewController: UIViewController {

    var getSocialView = DAGetSocialView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = true
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(getSocialView)
        getSocialView.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        getSocialView.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)
        getSocialView.autoPinEdgeToSuperviewEdge(ALEdge.Left)
        getSocialView.autoPinEdgeToSuperviewEdge(ALEdge.Right)
    }
}
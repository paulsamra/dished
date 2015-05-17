//
//  DARegisterViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DARegisterViewController2: DALoggedOutViewController {
    
    var registerView = DARegisterView()
    var facebookUser: NSDictionary?
    
    init() {
        facebookUser = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    init(facebookUser: NSDictionary) {
        self.facebookUser = facebookUser
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = registerView
    }
}
//
//  DASplashNavigator.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DASplashNavigator {
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func navigateToLoginView() {
        let loginViewController = DALoginViewController2()
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func navigateToRegisterView() {
        
    }
    
    func navigateToFacebookView() {
        
    }
}

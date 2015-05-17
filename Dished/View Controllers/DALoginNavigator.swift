//
//  DALoginNavigator.swift
//  Dished
//
//  Created by Ryan Khalili on 5/17/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DALoginNavigator {
    
    var navigationController: UINavigationController?
      
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func navigateToResetPasswordViewWithPhoneNumber(phoneNumber: String) {
        let resetPasswordViewController = DAResetPasswordViewController2(phoneNumber: phoneNumber)
        navigationController?.pushViewController(resetPasswordViewController, animated: true)
    }
    
    func navigateToForgotPasswordView() {
        let forgotPasswordViewController = DAVerifyPhoneNumberViewController()
        navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    func navigateToLoginView() {
        let loginViewController = DALoginViewController2()
        performNavigationWithDestinationViewController(loginViewController)
    }
    
    func navigateToRegisterProcess() {
        let registerPhoneViewController = DARegisterPhoneNumberViewController()
        performNavigationWithDestinationViewController(registerPhoneViewController)
    }
    
    func navigateToRegisterProcessWithFacebookUser(user: NSDictionary) {
        let registerPhoneViewController = DARegisterPhoneNumberViewController(facebookUser: user)
        performNavigationWithDestinationViewController(registerPhoneViewController)
    }
    
    func navigateToFacebookLoginView() {
        let facebookLoginViewController = DAFacebookLoginViewController2()
        performNavigationWithDestinationViewController(facebookLoginViewController)
    }
    
    func navigateToRegistrationForm() {
        let registerViewController = DARegisterViewController2()
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    func navigateToRegistrationFormWithFacebookUser(user: NSDictionary) {
        let registerViewController = DARegisterViewController2(facebookUser: user)
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    private func performNavigationWithDestinationViewController(destinationViewController: UIViewController) {
        let source = navigationController?.visibleViewController
        
        if navigationController?.viewControllers.count > 0 {
            let rootViewController = navigationController?.viewControllers[0] as! UIViewController
            
            if source! == rootViewController {
                navigationController?.pushViewController(destinationViewController, animated: true)
                return
            }
        }
        
        let destination = destinationViewController
        
        let controllerStack = navigationController?.viewControllers
        var stackCopy = NSMutableArray(array: controllerStack!)
        stackCopy.replaceObjectAtIndex(stackCopy.indexOfObject(source!), withObject: destination)
        navigationController?.setViewControllers(stackCopy as [AnyObject], animated: true)
    }
}
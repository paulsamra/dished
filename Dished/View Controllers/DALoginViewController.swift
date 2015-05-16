//
//  DALoginViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoginViewController2: DAViewController, DALoginViewDelegate {

    let loginView = DALoginView()
    
    var loginInteractor: DALoginViewInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginInteractor = DALoginViewInteractor(loginView: loginView)
        navigationItem.title = "Sign In"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loginInteractor.updateSignInButtonState()
    }
    
    func loginViewDidPressSignInButton(loginView: DALoginView) {
        var username = loginView.usernameField.text
        let password = loginView.passwordField.text
        
        if username[0] == "@" {
            username = username.substringFromIndex(advance(username.startIndex, 1))
        }
        
        loginView.showOverlay()
        
        DAAPIManager.sharedManager().loginWithUser(username, password: password, completion: {
            success, wrongUser, wrongPass, deactivated in
            
            if success {
                DAUserManager.sharedManager().loadUserInfoWithCompletion({
                    userLoadSuccess in
                    
                    self.loginView.hideOverlayWithCompletion({
                        if userLoadSuccess {
                            (UIApplication.sharedApplication().delegate as! DAAppDelegate).login()
                        }
                        else {
                            DAAPIManager.sharedManager().forceUserLogout()
                            self.showAlertWithTitle("Failed to Login", message: "There was a problem signing you in. Please try again.")
                        }
                    })
                })
            }
            else {
                var errorTitle = "Failed to Sign In"
                var errorMessage = "There was a problem signing you in. Please try again."
                
                if wrongUser {
                    errorTitle = "Incorrect Username or Email"
                    errorMessage = "The email or username you entered does not belong to an account."
                }
                else if wrongPass {
                    errorTitle = "Incorrect Password"
                    errorMessage = "The password you entered is incorrect. Please try again."
                }
                else if deactivated {
                    errorTitle = "Inactive Account"
                    errorMessage = "This account has been deactivated."
                }
                
                self.loginView.hideOverlayWithCompletion({
                    self.showAlertWithTitle(errorTitle, message: errorMessage)
                })
            }
        })
    }
    
    func loginViewDidPressRegisterButton(loginView: DALoginView) {
        let registerPhoneNumberViewController = DARegisterPhoneNumberViewController()
        navigationController?.pushViewController(registerPhoneNumberViewController, animated: true)
    }
    
    func loginViewDidPressFacebookButton(loginView: DALoginView) {
        let readPermissions = [
            "public_profile",
            "email",
            "user_friends"
        ]
        
        FBSession.openActiveSessionWithReadPermissions(readPermissions, allowLoginUI: true,
        completionHandler: {
            session, state, error in
            
            if state == FBSessionState.Open {
                    
            }
                
            let appDelegate = UIApplication.sharedApplication().delegate as! DAAppDelegate
            appDelegate.sessionStateChanged(session, state: state, error: error)
        })
    }
    
    func loginViewDidPressForgotPasswordButton(loginView: DALoginView) {
        let verifyPhoneNumberViewController = DAVerifyPhoneNumberViewController()
        navigationController?.pushViewController(verifyPhoneNumberViewController, animated: true)
    }
    
    override func loadView() {
        loginView.delegate = self
        view = loginView
    }
}
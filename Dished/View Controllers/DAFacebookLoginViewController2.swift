//
//  DAFacebookLoginViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFacebookLoginViewController2: DALoggedOutViewController {

    let facebookLoginView = DAFacebookLoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginView.spinner.startAnimating()
        startFacebookLoginProcess()
    }
    
    private func startFacebookLoginProcess() {
        let parameters = [
            "fields": "id,name,first_name,last_name,email,picture.width(400).height(400)"
        ]
        
        FBRequestConnection.startWithGraphPath("me", parameters: parameters, HTTPMethod: "GET", completionHandler: {
            connection, result, error in
            
            if error == nil {
                if let user = result as? NSDictionary {
                    self.attemptFacebookLoginWithFacebookUser(user)
                    return
                }
            }
            
            self.failedToGetFacebookUser()
        })
    }
    
    private func attemptFacebookLoginWithFacebookUser(user: NSDictionary) {
        if let userID = user.objectForKey(kIDKey) as? String {
            DAAPIManager.sharedManager().loginWithFacebookUserID(userID, completion: {
                success, accountExists in
                
                if success {
                    let appDelegate = UIApplication.sharedApplication().delegate as! DAAppDelegate
                    appDelegate.followFacebookFriends()
                    appDelegate.login()
                }
                else if !accountExists {
                    self.goToRegisterWithFacebookUser(user)
                }
                else {
                    self.failedToGetFacebookUser()
                }
            })
        }
        else {
            failedToGetFacebookUser()
        }
    }
    
    private func failedToGetFacebookUser() {
        UIAlertView(title: "An error occured.", message: "There was an error logging you into Facebook. Please try again.", delegate: nil, cancelButtonTitle: "OK").show()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        FBSession.activeSession().closeAndClearTokenInformation()
    }
    
    func goToRegisterWithFacebookUser(user: NSDictionary) {
        navigator.navigateToRegisterProcessWithFacebookUser(user)
    }
    
    override func loadView() {
        view = facebookLoginView
    }
}
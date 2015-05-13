//
//  DAInitialViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DASplashViewController2: UIViewController, DAWelcomeViewDelegate, DASplashViewDelegate {

    var splashView: DASplashView!
    
    lazy var splashNavigator: DASplashNavigator = {
        return DASplashNavigator(navigationController: self.navigationController)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let firstLaunch = userDefaults.objectForKey(kFirstLaunchKey) as? String
        if firstLaunch == nil {
            splashView.showWelcomeView()
            userDefaults.setObject("firstLaunch", forKey: kFirstLaunchKey)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return splashView.welcomeViewVisible ? UIStatusBarStyle.Default : UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        FBSession.activeSession().closeAndClearTokenInformation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func welcomeViewDidFinish(welcomeView: DAWelcomeView) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func splashViewDidPressSignInButton(splashView: DASplashView) {
        splashNavigator.navigateToLoginView()
    }
    
    func splashViewDidPressRegisterButton(splashView: DASplashView) {
        splashNavigator.navigateToRegisterView()
    }
    
    func splashViewDidPressFacebookButton(splashView: DASplashView) {
        connectToFacebook()
    }
    
    func connectToFacebook() {
        let readPermissions = [
            "public_profile",
            "email",
            "user_friends"
        ]
        
        FBSession.openActiveSessionWithReadPermissions(readPermissions, allowLoginUI: true,
        completionHandler: {
            session, state, error in
            
            if state == FBSessionState.Open {
                self.splashNavigator.navigateToFacebookView()
            }
            
            let appDelegate = UIApplication.sharedApplication().delegate as! DAAppDelegate
            appDelegate.sessionStateChanged(session, state: state, error: error)
        })
    }

    override func loadView() {
        splashView = DASplashView()
        splashView.welcomeView.delegate = self
        splashView.delegate = self
        view = splashView
    }
}
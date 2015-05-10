//
//  DAShareSettingsDataSource.swift
//  Dished
//
//  Created by Ryan Khalili on 5/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DAShareSettingsDataSource {
    
    private let userManager = DAUserManager2()
    
    let sharingServices = [
        "Facebook",
        "Twitter"
    ]
    
    private func facebookIsConnected() -> Bool {
        let isFacebookUser = userManager.isFacebookUser
        
        let facebookOpenTokenState = FBSession.activeSession().state != FBSessionState.OpenTokenExtended
        let facebookOpenState = FBSession.activeSession().state != FBSessionState.Open
        
        let facebookLoggedOut = facebookOpenTokenState && facebookOpenState
        
        return isFacebookUser || !facebookLoggedOut
    }
    
    private func twitterIsLoggedIn() -> Bool {
        return DATwitterManager.sharedManager().isLoggedIn()
    }
    
    func sharingServiceIsConfigurable(service: String) -> Bool {
        if service == sharingServices[0] {
            return false
        }
        else if service == sharingServices[1] {
            return true
        }
        else {
            return false
        }
    }
    
    func socialMediaTypeForSharingService(service: String) -> eSocialMediaType? {
        if service == sharingServices[0] {
            return eSocialMediaTypeFacebook
        }
        else if service == sharingServices[1] {
            return eSocialMediaTypeTwitter
        }
        else {
            return nil
        }
    }
    
    func sharingServiceIsConnected(service: String) -> Bool {
        if service == sharingServices[0] {
            return facebookIsConnected()
        }
        else if service == sharingServices[1] {
            return twitterIsLoggedIn()
        }
        else {
            return false
        }
    }
}
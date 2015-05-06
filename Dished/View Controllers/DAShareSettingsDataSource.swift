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
    
    func facebookIsConnected() -> Bool {
        let isFacebookUser = userManager.isFacebookUser
        
        let facebookOpenTokenState = FBSession.activeSession().state != FBSessionState.OpenTokenExtended
        let facebookOpenState = FBSession.activeSession().state != FBSessionState.Open
        
        let facebookLoggedOut = facebookOpenTokenState && facebookOpenState
        
        return isFacebookUser || !facebookLoggedOut
    }
}
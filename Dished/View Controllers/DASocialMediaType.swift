//
//  DASocialMediaType.swift
//  Dished
//
//  Created by Ryan Khalili on 5/10/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

@objc enum DASocialMediaType: Int {
    case Facebook, Twitter, Email
    
    var name: String {
        switch(self) {
        case .Facebook: return "Facebook"
        case .Twitter: return "Twitter"
        case .Email: return "Email"
        }
    }
    
    var configurable: Bool {
        switch(self) {
        case .Facebook: return false
        case .Twitter: return true
        case .Email: return false
        }
    }
    
    var connected: Bool {
        switch(self) {
            case .Facebook: return isFacebookConnected()
            case .Twitter: return isTwitterConnected()
            case .Email: return true
        }
    }
    
    func connectWithCompletion(completion: (Bool) -> ()) {
        switch(self) {
            case .Facebook: connectToFacebookWithCompletion(completion)
            case .Twitter: connectToTwitterWithCompletion(completion)
            case .Email: completion(true)
        }
    }
    
    func disconnectWithCompletion(completion: (Bool) -> ()) {
        switch(self) {
            case .Facebook: disconnectFromFacebookWithCompletion(completion)
            case .Twitter: disconnectFromTwitterWithCompletion(completion)
            case .Email: completion(true)
        }
    }
    
    private func connectToFacebookWithCompletion(completion: (Bool) -> ()) {
        completion(true)
    }
    
    private func connectToTwitterWithCompletion(completion: (Bool) -> ()) {
        DATwitterManager.sharedManager().loginWithCompletion({
            success in
            completion(success)
            return
        })
    }
    
    private func disconnectFromFacebookWithCompletion(completion: (Bool) -> ()) {
        completion(true)
    }
    
    private func disconnectFromTwitterWithCompletion(completion: (Bool) -> ()) {
        DATwitterManager.sharedManager().logout()
        completion(!DATwitterManager.sharedManager().isLoggedIn())
    }
    
    private func isFacebookConnected() -> Bool {
        let userManager = DAUserManager2()
        let isFacebookUser = userManager.isFacebookUser
        
        let facebookOpenTokenState = FBSession.activeSession().state != FBSessionState.OpenTokenExtended
        let facebookOpenState = FBSession.activeSession().state != FBSessionState.Open
        
        let facebookLoggedOut = facebookOpenTokenState && facebookOpenState
        
        return isFacebookUser || !facebookLoggedOut
    }
    
    private func isTwitterConnected() -> Bool {
        return DATwitterManager.sharedManager().isLoggedIn()
    }
}
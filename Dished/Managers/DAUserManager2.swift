//
//  DAUserManager2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/5/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

@objc enum DAPushSetting: Int {
    case Off
    case Followed
    case Everyone
    
    init(string: String) {
        switch(string) {
            case kNone:   self = .Off
            case kFollow: self = .Followed
            case kAll:    self = .Everyone
            default:      self = .Off
        }
    }
    
    func string() -> String {
        switch(self) {
            case .Off:      return kNone
            case .Followed: return kFollow
            case .Everyone: return kAll
            default:        return kNone
        }
    }
}

class DAUserManager2 {
    
    private(set) var dateOfBirth = NSDate()
    private(set) var description = ""
    private(set) var email = ""
    private(set) var username = ""
    private(set) var userType = ""
    private(set) var firstName = ""
    private(set) var lastName = ""
    private(set) var image = ""
    private(set) var zipCode = ""
    private(set) var phoneNumber = ""
    private(set) var isFacebookUser = false
    private(set) var userID = 0
    private var regType = ""
    
    private static let userProfileKey = "userManager-profile"
    private static let userProfileDeletedNotificationKey = "Dished-UserProfileDeleted"
    private static let userProfileUpdatedNotificationKey = "Dished-UserProfileUpdated"
    
    var savesDishPhoto = false {
        didSet {
            savesDishPhotoTask?.cancel()
            let parameters = [kSavePhotoKey: savesDishPhoto]
            saveSettingToServerWithParameters(parameters, forTask: &savesDishPhotoTask)
        }
    }
    
    var publicProfile = false {
        didSet {
            publicProfileTask?.cancel()
            let parameters = [kPublicKey: publicProfile]
            saveSettingToServerWithParameters(parameters, forTask: &publicProfileTask)
        }
    }
    
    var yumPushSetting = DAPushSetting.Off {
        didSet {
            yumPushSettingTask?.cancel()
            let parameters = [kPushYumKey: yumPushSetting.string()]
            saveSettingToServerWithParameters(parameters, forTask: &yumPushSettingTask)
        }
    }
    
    var commentPushSetting = DAPushSetting.Off {
        didSet {
            commentPushSettingTask?.cancel()
            let parameters = [kPushCommentKey: commentPushSetting.string()]
            saveSettingToServerWithParameters(parameters, forTask: &commentPushSettingTask)
        }
    }
    
    private var savesDishPhotoTask: NSURLSessionTask?
    private var publicProfileTask: NSURLSessionTask?
    private var yumPushSettingTask: NSURLSessionTask?
    private var commentPushSettingTask: NSURLSessionTask?
    
    init() {
        loadSavedProfile()
        loadSavedSettings()
    }
    
    private func loadSavedProfile() {
        let profileKey = DAUserManager2.userProfileKey
        let data = NSUserDefaults.standardUserDefaults().objectForKey(profileKey) as? [String:AnyObject]
        
        if let savedProfile = data  {
            firstName   = savedProfile[kFirstNameKey]   as? String ?? ""
            lastName    = savedProfile[kLastNameKey]    as? String ?? ""
            email       = savedProfile[kEmailKey]       as? String ?? ""
            description = savedProfile[kDescriptionKey] as? String ?? ""
            phoneNumber = savedProfile[kPhoneKey]       as? String ?? ""
            dateOfBirth = savedProfile[kDateOfBirthKey] as? NSDate ?? NSDate()
            image       = savedProfile[kImgThumbKey]    as? String ?? ""
            zipCode     = savedProfile["zip"]           as? String ?? ""
            username    = savedProfile[kUsernameKey]    as? String ?? ""
            userType    = savedProfile[kTypeKey]        as? String ?? ""
            
            userID = savedProfile[kIDKey]?.integerValue ?? 0
            
            regType = savedProfile[kRegTypeKey] as? String ?? ""
            isFacebookUser = regType == "facebook"
        }
    }
    
    private func loadSavedSettings() {
        let profileKey = DAUserManager2.userProfileKey
        let data = NSUserDefaults.standardUserDefaults().objectForKey(profileKey) as? [String:AnyObject]
        
        if let savedProfile = data {
            publicProfile  = savedProfile[kPublicKey]?.boolValue ?? false
            savesDishPhoto = savedProfile[kSavePhotoKey]?.boolValue ?? false
            
            yumPushSetting = DAPushSetting(string: savedProfile[kPushYumKey] as? String ?? "")
            commentPushSetting = DAPushSetting(string: savedProfile[kPushCommentKey] as? String ?? "")
        }
    }
    
    class func loadCurrentUserWithCompletion(completion: (success: Bool) -> ()) {
        loadUserProfileWithCompletion({
            profileSuccess in
            self.loadUserSettingsWithCompletion({
                settingsSuccess in
                completion(success: profileSuccess && settingsSuccess)
            })
        })
    }
    
    private class func loadUserSettingsWithCompletion(completion: (success: Bool) -> ()) {
        DAAPIManager.sharedManager().GETRequest(kUserSettingsURL, withParameters: nil, success: {
            response in
            
            
        },
        failure: {
            error, retry in
            retry ? self.loadUserSettingsWithCompletion(completion) : completion(success: false)
        })
    }
    
    private class func loadUserProfileWithCompletion(completion: (success: Bool) -> ()) {
        DAAPIManager.sharedManager().GETRequest(kUsersURL, withParameters: nil, success: {
            response in
            
            
        },
        failure: {
            error, retry in
            retry ? self.loadUserProfileWithCompletion(completion) : completion(success: false)
        })
    }
    
    class func removeCurrentSavedUserData() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(userProfileKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func userProfileDeleted() {
        resetUserInfo()
    }
    
    private func saveSettingToServerWithParameters(parameters: [NSObject: AnyObject], inout forTask task: NSURLSessionTask?) {
        let url = kUserSettingsURL
        task = DAAPIManager.sharedManager().POSTRequest(url, withParameters: parameters, success: nil,
        failure: {
            error, retry in
            
            if retry {
                self.saveSettingToServerWithParameters(parameters, forTask: &task)
            }
        })
    }
    
    func deleteUserProfile() {
        resetUserInfo()
        DAUserManager2.removeCurrentSavedUserData()
    }
    
    func resetUserInfo() {
        dateOfBirth = NSDate()
        firstName = ""
        lastName = ""
        email = ""
        description = ""
        phoneNumber = ""
        username = ""
        userType = ""
        image = ""
        zipCode = ""
    }
}
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
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(profileKey) as? [String:AnyObject] {
            setProfileWithData(data)
        }
    }
    
    private func setProfileWithData(data: NSDictionary) {
        firstName   = data[kFirstNameKey]   as? String ?? ""
        lastName    = data[kLastNameKey]    as? String ?? ""
        email       = data[kEmailKey]       as? String ?? ""
        description = data[kDescriptionKey] as? String ?? ""
        phoneNumber = data[kPhoneKey]       as? String ?? ""
        dateOfBirth = data[kDateOfBirthKey] as? NSDate ?? NSDate()
        image       = data[kImgThumbKey]    as? String ?? ""
        zipCode     = data["zip"]           as? String ?? ""
        username    = data[kUsernameKey]    as? String ?? ""
        userType    = data[kTypeKey]        as? String ?? ""
        
        userID = data[kIDKey]?.integerValue ?? 0
        
        regType = data[kRegTypeKey] as? String ?? ""
        isFacebookUser = regType == "facebook"
    }
    
    private func loadSavedSettings() {
        let profileKey = DAUserManager2.userProfileKey
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(profileKey) as? [String:AnyObject] {
            setSettingsWithData(data)
        }
    }
    
    private func setSettingsWithData(data: NSDictionary) {
        publicProfile  = data[kPublicKey]?.boolValue ?? false
        savesDishPhoto = data[kSavePhotoKey]?.boolValue ?? false
        
        yumPushSetting = DAPushSetting(string: data[kPushYumKey] as? String ?? "")
        commentPushSetting = DAPushSetting(string: data[kPushCommentKey] as? String ?? "")
    }
    
    class func loadCurrentUserWithCompletion(completion: (success: Bool) -> ()) {
        if !DAAPIManager.sharedManager().isLoggedIn() {
            completion(success: false)
            return
        }
        
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
            
            if let data = response.objectForKey(kDataKey) as? NSDictionary {
                self.saveSettingsWithData(data)
            }
            else {
                completion(success: false)
            }
        },
        failure: {
            error, retry in
            retry ? self.loadUserSettingsWithCompletion(completion) : completion(success: false)
        })
    }
    
    private class func loadUserProfileWithCompletion(completion: (success: Bool) -> ()) {
        DAAPIManager.sharedManager().GETRequest(kUsersURL, withParameters: nil, success: {
            response in
            
            if let data = response.objectForKey(kDataKey) as? NSDictionary {
                self.saveProfileWithData(data)
            }
            else {
                completion(success: false)
            }
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
    
    private func resetUserInfo() {
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
    
    private class func saveProfileWithData(data: NSDictionary) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var saved = userDefaults.objectForKey(userProfileKey) as? [String:AnyObject]
        var profile = saved ?? [String:AnyObject]()

        profile["zip"] = data["zip"]
        profile[kDateOfBirthKey] = data[kDateOfBirthKey]
        profile[kFirstNameKey] = data[kFirstNameKey]
        profile[kLastNameKey] = data[kLastNameKey]
        profile[kEmailKey] = data[kEmailKey]
        profile[kDescriptionKey] = data[kDescriptionKey]
        profile[kPhoneKey] = data[kPhoneKey]
        profile[kUsernameKey] = data[kUsernameKey]
        profile[kTypeKey] = data[kTypeKey]
        profile[kImgThumbKey] = data[kImgThumbKey]
        
        NSUserDefaults.standardUserDefaults().setObject(profile, forKey: DAUserManager2.userProfileKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private class func saveSettingsWithData(data: NSDictionary) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var saved = userDefaults.objectForKey(userProfileKey) as? [String:AnyObject]
        var profile = saved ?? [String:AnyObject]()
        
        profile[kPublicKey] = data[kPublicKey]?.boolValue ?? false
        profile[kSavePhotoKey] = data[kSavePhotoKey]?.boolValue ?? false
        
        profile[kPushYumKey] = data[kPushYumKey]
        profile[kPushCommentKey] = data[kPushCommentKey]
        
        NSUserDefaults.standardUserDefaults().setObject(profile, forKey: DAUserManager2.userProfileKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
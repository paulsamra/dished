//
//  DANotificationSettingsDataSource.swift
//  Dished
//
//  Created by Ryan Khalili on 5/10/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

class DANotificationSettingsDataSource {
    
    let userManager = DAUserManager2()
    
    let pushSettings = [
        DAPushSetting.Off,
        DAPushSetting.Followed,
        DAPushSetting.Everyone
    ]
    
    func currentPushSettingForNotificationSettingType(notificationSettingType: DANotificationSettingType) -> DAPushSetting {
        switch(notificationSettingType) {
            case .Yum: return userManager.yumPushSetting
            case .Comment: return userManager.commentPushSetting
        }
    }
}
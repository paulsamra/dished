//
//  DASettingsDataSource.swift
//  Dished
//
//  Created by Ryan Khalili on 5/5/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DASettingsDataSource {
    
    let sectionNames = [
        "Account",
        "Push Notifications",
        "Privacy",
        "Save Photos to Library",
        "Terms"
    ]
    
    let sectionFooters = [
        "",
        "You can edit additional notifications preferences in the Settings section of your phone.",
        "Turn privacy OFF if you want to allow others to follow and view your profile and reviews. Your reviews will not show up publicly nor will your ratings be active unless your account is public.",
        "Select ON for Dished to save photos you take to your Camera Roll.",
        ""
    ]

    private let settings: [String:([String], [DASettingsTableViewCellStyle])] = [
        "Account": (
            [
                "Profile Details",
                "Share Settings",
                "Log Out"
            ],
            [
                DASettingsTableViewCellStyle.Plain,
                DASettingsTableViewCellStyle.Plain,
                DASettingsTableViewCellStyle.Destructive
            ]
        ),
        "Push Notifications": (
            [
                "YUM Notifications",
                "Comment Notifications"
            ],
            [
                DASettingsTableViewCellStyle.Plain,
                DASettingsTableViewCellStyle.Plain
            ]
        ),
        "Privacy": (
            ["Profile Privacy"],
            [DASettingsTableViewCellStyle.Switch]
        ),
        "Save Photos to Library": (
            ["Dish Photos"],
            [DASettingsTableViewCellStyle.Switch]
        ),
        "Terms": (
            [
                kPrivacyPolicy,
                kTermsAndConditions
            ],
            [
                DASettingsTableViewCellStyle.Plain,
                DASettingsTableViewCellStyle.Plain
            ]
        )
    ]
    
    var userManager = DAUserManager2()
    
    func settingsForSection(section: String) -> [String] {
        return settings[section]?.0 ?? []
    }
    
    func cellStyleForSettingIndex(index: Int, inSection section: String) -> DASettingsTableViewCellStyle {
        let styles = settings[section]?.1 ?? []
        return index >= styles.count ? DASettingsTableViewCellStyle.Plain : styles[index]
    }
    
    func stateForSetting(setting: String) -> Bool {
        if setting == settings["Privacy"]?.0[0] {
            return !userManager.publicProfile
        }
        else if setting == settings["Save Photos to Library"]?.0[0] {
            return userManager.savesDishPhoto
        }
        
        return false
    }
    
    func settingIsLogout(setting: String) -> Bool {
        return setting == "Log Out"
    }
    
    func viewControllerForSetting(setting: String) -> UIViewController? {
        var viewController: UIViewController?
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch(setting) {
            case "Profile Details": viewController = storyboard.instantiateViewControllerWithIdentifier("editProfile") as? UIViewController
            case "Share Settings": viewController = DAShareSettingsViewController()
            case "YUM Notifications": viewController = DANotificationSettingsViewController(notificationSetting: DANotificationSetting.Yum)
            case "Comment Notifications": viewController = DANotificationSettingsViewController(notificationSetting: DANotificationSetting.Comment)
            case kPrivacyPolicy: viewController = documentViewWithName(setting)
            case kTermsAndConditions: viewController = documentViewWithName(setting)
            default: viewController = nil
        }
        
        return viewController
    }
    
    func logoutWithCompletion(completion: (Bool) -> ()) {
        DAAPIManager.sharedManager().logoutWithCompletion({
            success in
            
            completion(success)
            return
        })
    }
    
    func toggledSetting(setting: String, toState state: Bool) {
        switch(setting) {
            case "Profile Privacy": userManager.publicProfile = !state
            case "Dish Photos": userManager.savesDishPhoto = state
            default: return
        }
    }
    
    private func documentViewWithName(name: String) -> DADocViewController? {
        if let filePath = NSBundle.mainBundle().pathForResource(name, ofType: "html") {
            return DADocViewController(filePath: filePath, title: name)
        }
        
        return nil
    }
}
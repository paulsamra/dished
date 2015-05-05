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
                "Privacy Policy",
                "Terms of Services"
            ],
            [
                DASettingsTableViewCellStyle.Plain,
                DASettingsTableViewCellStyle.Plain
            ]
        )
    ]
    
    func settingsForSection(section: String) -> [String] {
        return settings[section]?.0 ?? []
    }
    
    func cellStyleForSettingIndex(index: Int, inSection section: String) -> DASettingsTableViewCellStyle {
        let styles = settings[section]?.1 ?? []
        return index >= styles.count ? DASettingsTableViewCellStyle.Plain : styles[index]
    }
}
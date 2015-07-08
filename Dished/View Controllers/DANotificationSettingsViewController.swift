//
//  DANotificationSettingsViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

enum DANotificationSettingType {
    case Yum
    case Comment
    
    func name() -> String {
        switch(self) {
            case .Yum: return "YUM Notifications"
            case .Comment: return "Comment Notifications"
        }
    }
}

class DANotificationSettingsViewController: DAViewController, UITableViewDelegate, UITableViewDataSource {

    var notificationSettingsView = DANotificationSettingsView()
    let notificationSettingsDataSource = DANotificationSettingsDataSource()
    var notificationSetting = DANotificationSettingType.Yum
    
    private let cellIdentifier = "notificationSettingCell"
    
    init(notificationSetting: DANotificationSettingType) {
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = notificationSetting.name()
        self.notificationSetting = notificationSetting
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationSettingsView.tableView.delegate = self
        notificationSettingsView.tableView.dataSource = self
        notificationSettingsView.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        
        let pushSetting = notificationSettingsDataSource.pushSettings[indexPath.row]
        cell.textLabel?.text = pushSetting.name()
        cell.textLabel?.font = DAConstants.primaryFontWithSize(17.0)
        
        let checkmark = UITableViewCellAccessoryType.Checkmark
        let isSelected = pushSetting == notificationSettingsDataSource.currentPushSettingForNotificationSettingType(notificationSetting)
        cell.accessoryType = isSelected ? checkmark : UITableViewCellAccessoryType.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dataSource = notificationSettingsDataSource
        let pushSetting = dataSource.pushSettings[indexPath.row]
        
        switch(notificationSetting) {
            case .Yum: dataSource.userManager.yumPushSetting = pushSetting
            case .Comment: dataSource.userManager.commentPushSetting = pushSetting
        }
        
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    override func loadView() {
        view = notificationSettingsView
    }
}
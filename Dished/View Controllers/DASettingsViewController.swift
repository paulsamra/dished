//
//  DASettingsViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/5/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DASettingsViewController: DAViewController, UITableViewDelegate, UITableViewDataSource, DASettingsTableViewCellDelegate, UIActionSheetDelegate {

    let settingsView = DASettingsView()
    let settingsDataSource = DASettingsDataSource()
    
    let cellIdentifier = "settingCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsView.tableView.delegate = self
        settingsView.tableView.dataSource = self
        settingsView.tableView.registerClass(DASettingsTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        settingsView.tableView.deselectSelectedIndexPath()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settingsDataSource.sectionNames.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = settingsDataSource.sectionNames[section]
        return settingsDataSource.settingsForSection(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! DASettingsTableViewCell
        
        let section = settingsDataSource.sectionNames[indexPath.section]
        let settings = settingsDataSource.settingsForSection(section)
        
        let style = settingsDataSource.cellStyleForSettingIndex(indexPath.row, inSection: section)
        cell.style = style
        cell.textLabel?.text = settings[indexPath.row]
        cell.delegate = self
        
        if style == DASettingsTableViewCellStyle.Switch {
            cell.selectorSwitch.on = settingsDataSource.stateForSetting(settings[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = settingsDataSource.sectionNames[indexPath.section]
        let settings = settingsDataSource.settingsForSection(section)
        let setting = settings[indexPath.row]
        
        if let destination = settingsDataSource.viewControllerForSetting(setting) {
            navigationController?.pushViewController(destination, animated: true)
        }
        else {
            tableView.deselectSelectedIndexPath()
            
            if settingsDataSource.settingIsLogout(setting) {
                showLogoutPrompt()
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsDataSource.sectionNames[section]
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return settingsDataSource.sectionFooters[section]
    }
    
    func settingsTableViewCell(cell: DASettingsTableViewCell, didSetSwitchOn on: Bool) {
        if let indexPath = settingsView.tableView.indexPathForView(cell.selectorSwitch) {
            let section = settingsDataSource.sectionNames[indexPath.section]
            let settings = settingsDataSource.settingsForSection(section)
            let setting = settings[indexPath.row]
            settingsDataSource.toggledSetting(setting, toState: on)
        }
    }
    
    private func showLogoutPrompt() {
        let actionSheet = UIActionSheet(title: "Are you sure you want to Log Out?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Log Out")
        actionSheet.showInView(view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == actionSheet.destructiveButtonIndex {
            logout()
        }
    }
    
    private func logout() {
        MRProgressOverlayView.showOverlayAddedTo(view, title: "Logging Out...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        
        settingsDataSource.logoutWithCompletion({
            success in
            
            if success {
                (UIApplication.sharedApplication().delegate as! DAAppDelegate).logout()
            }
            else {
                UIAlertView(title: "Failed to Log Out", message: "There was a problem logging you out. Please try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }

        })
    }
    
    override func loadView() {
        view = settingsView
        
        navigationItem.title = "Settings"
    }
}
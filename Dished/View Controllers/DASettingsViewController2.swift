//
//  DASettingsViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/5/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DASettingsViewController2: DAViewController, UITableViewDelegate, UITableViewDataSource {

    let settingsView = DASettingsView()
    let settingsDataSource = DASettingsDataSource()
    
    let cellIdentifier = "settingCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsView.tableView.delegate = self
        settingsView.tableView.dataSource = self
        settingsView.tableView.registerClass(DASettingsTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
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
        
        if style == DASettingsTableViewCellStyle.Switch {
            cell.selectorSwitch.on = settingsDataSource.stateForSetting(settings[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsDataSource.sectionNames[section]
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return settingsDataSource.sectionFooters[section]
    }
    
    override func loadView() {
        view = settingsView
        
        navigationItem.title = "Settings"
    }
}
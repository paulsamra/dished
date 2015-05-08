//
//  DAShareSettingsViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAShareSettingsViewController2: DAViewController, UITableViewDelegate, UITableViewDataSource {
    
    let shareSettingsView = DAShareSettingsView()
    let shareSettingsDataSource = DAShareSettingsDataSource()
    
    let cellIdentifier = "shareCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shareSettingsView.tableView.delegate = self
        shareSettingsView.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        shareSettingsView.tableView.deselectSelectedIndexPath()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareSettingsDataSource.sharingServices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        }
        
        let sharingService = shareSettingsDataSource.sharingServices[indexPath.row]
        cell!.textLabel?.text = sharingService
        cell!.textLabel?.font = DAConstants.primaryFontWithSize(17.0)
        
        let connected = shareSettingsDataSource.sharingServiceIsConnected(sharingService)
        cell!.detailTextLabel?.text = connected ? "Connected" : "Not Connected"
        cell!.detailTextLabel?.textColor = connected ? UIColor.blueColor() : UIColor.lightGrayColor()
        cell!.detailTextLabel?.font = DAConstants.primaryFontWithSize(17.0)
        
        let disclosureIndicator = UITableViewCellAccessoryType.DisclosureIndicator
        let configurable = shareSettingsDataSource.sharingServiceIsConfigurable(sharingService)
        cell!.accessoryType = configurable ? disclosureIndicator : UITableViewCellAccessoryType.None
        cell!.userInteractionEnabled = configurable
        
        return cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Accounts"
    }
    
    override func loadView() {
        view = shareSettingsView
        
        navigationItem.title = "Share Settings"
    }
}
//
//  DAShareSettingsViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 5/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAShareSettingsViewController: DAViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        
        shareSettingsView.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareSettingsDataSource.socialMedia.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier)
        }
        
        let socialMedia = shareSettingsDataSource.socialMedia[indexPath.row]
        cell!.textLabel?.text = socialMedia.name
        cell!.textLabel?.font = DAConstants.primaryFontWithSize(17.0)
        
        cell!.detailTextLabel?.text = socialMedia.connected ? "Connected" : "Not Connected"
        cell!.detailTextLabel?.textColor = socialMedia.connected ? UIColor.dishedColor() : UIColor.lightGrayColor()
        cell!.detailTextLabel?.font = DAConstants.primaryFontWithSize(17.0)
        
        let disclosureIndicator = UITableViewCellAccessoryType.DisclosureIndicator
        let configurable = socialMedia.configurable
        cell!.accessoryType = configurable ? disclosureIndicator : UITableViewCellAccessoryType.None
        cell!.userInteractionEnabled = configurable
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let socialMedia = shareSettingsDataSource.socialMedia[indexPath.row]
        
        if socialMedia.configurable {
            if let shareLinkViewController = DAShareLinkViewController(socialMediaType: socialMedia) {
                navigationController?.pushViewController(shareLinkViewController, animated: true)
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Accounts"
    }
    
    override func loadView() {
        view = shareSettingsView
        
        navigationItem.title = "Share Settings"
    }
}
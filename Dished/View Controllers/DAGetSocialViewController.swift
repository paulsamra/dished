//
//  DAGetSocialViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAGetSocialViewController: DAViewController, UITableViewDataSource, UITableViewDelegate {

    var getSocialView = DAGetSocialView()
    
    let cellTitles = [
        "Find Friends from Contacts",
        "Active Foodies in your Area"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSocialView.tableView.delegate = self
        getSocialView.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getSocialView.tableView.deselectSelectedIndexPath()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
            case 0:  showFindFriends()
            case 1:  showActiveFoodies()
            default: break;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        cell!.textLabel?.text = cellTitles[indexPath.row]
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell!.textLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        
        return cell!
    }
    
    private func showFindFriends() {
        let findFriendsViewController = DAFindFriendsViewController()
        navigationController?.pushViewController(findFriendsViewController, animated: true)
    }
    
    private func showActiveFoodies() {
        let activeFoodiesViewController = DAActiveFoodiesViewController()
        navigationController?.pushViewController(activeFoodiesViewController, animated: true)
    }
    
    override func loadView() {
        view = getSocialView
        
        navigationItem.title = "Get Social"
        getSocialView.skipButton.hidden = true
    }
}
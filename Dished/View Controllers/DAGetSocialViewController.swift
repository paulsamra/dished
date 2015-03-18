//
//  DAGetSocialViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAGetSocialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var getSocialView = DAGetSocialView()
    private var showSkipButton = false
    
    let cellTitles = [
        "Find Friends from Contacts",
        "Active Foodies in your Area"
    ]
    
    init(showSkipButton: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.showSkipButton = showSkipButton
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSocialView.tableView.delegate = self
        getSocialView.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let findFriendsViewController = storyboard.instantiateViewControllerWithIdentifier("inviteFriends") as UIViewController
        navigationController?.pushViewController(findFriendsViewController, animated: true)
    }
    
    private func showActiveFoodies() {
        
    }
    
    override func loadView() {
        view = getSocialView
        
        if navigationController?.navigationBar != nil {
            let navigationBarFrame = navigationController!.navigationBar.bounds
            let tableViewInset = UIApplication.sharedApplication().statusBarFrame.size.height + navigationBarFrame.size.height
            getSocialView.tableView.contentInset = UIEdgeInsetsMake(tableViewInset, 0, 0, 0)
        }
        
        navigationItem.title = "Get Social"
        getSocialView.skipButton.hidden = !showSkipButton
    }
}
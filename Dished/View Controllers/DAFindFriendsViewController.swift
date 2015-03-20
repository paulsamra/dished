//
//  DAFindFriendsViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFindFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var findFriendsView = DAFindFriendsView()
    var friendsController = DAFindFriendsController()
    let cellIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findFriendsView.tableView.registerClass(DAUserListTableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        
        findFriendsView.tableView.delegate = self
        findFriendsView.tableView.dataSource = self
        
        findFriendsView.showSpinner()
        friendsController.getFriends({
            success in
            
            if success {
                self.findFriendsView.tableView.reloadData()
            }
            else {
                self.findFriendsView.tableView.hidden = true
                self.findFriendsView.errorLabel.text = "Failed to load contacts."
            }
            
            self.findFriendsView.hideSpinner()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsController.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as DAUserListTableViewCell
        
        let friend = friendsController.friends[indexPath.row]
        
        cell.textLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        cell.textLabel?.text = friend.name
        
        if friend.registered {
            cell.sideButton.setTitle("Unfollow", forState: UIControlState.Normal)
            cell.sideButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        }
        else if friend.invited {
            cell.sideButton.setTitle("Invited", forState: UIControlState.Normal)
            cell.sideButton.setTitleColor(UIColor.dishedColor(), forState: UIControlState.Normal)
        }
        else {
            cell.sideButton.setTitle("Invite", forState: UIControlState.Normal)
            cell.sideButton.setTitleColor(UIColor.followButtonColor(), forState: UIControlState.Normal)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    override func loadView() {
        view = findFriendsView
        adjustInsetsForScrollView(findFriendsView.tableView)
    }
}
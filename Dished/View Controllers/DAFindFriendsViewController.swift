//
//  DAFindFriendsViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit
import MessageUI

class DAFindFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var findFriendsView = DAFindFriendsView()
    var friendsController = DAFindFriendsController()
    let cellIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findFriendsView.tableView.registerClass(DAUserListTableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        
        findFriendsView.tableView.delegate = self
        findFriendsView.tableView.dataSource = self
        
        loadContacts()
    }
    
    private func loadContacts() {
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
        return friendsController.friends.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as DAUserListTableViewCell
        
        let friend = friendsController.friends[indexPath.row]
        
        cell.textLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        cell.textLabel?.text = friend.name
        cell.sideButton.addTarget(self, action: "sideButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
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
    
    func sideButtonPressed(button: UIButton) {
        let tableView = findFriendsView.tableView
        var buttonPosition: CGPoint = button.convertPoint(CGPointZero, toView: tableView)
        var indexPath: NSIndexPath = tableView.indexPathForRowAtPoint(buttonPosition)!
        let friend = friendsController.friends[indexPath.row]
        
        if friend.registered {
            
        }
        else if friend.invited {
            
        }
        else {
            showMessageControllerForFriend(friend)
        }
    }
    
    func showMessageControllerForFriend(friend: DAFriend) {
        if !MFMessageComposeViewController.canSendText() {
            return
        }
        
        let recipients = [friend.phoneNumber]
        
        let messageController = MFMessageComposeViewController()
        messageController.recipients = recipients
        
        presentViewController(messageController, animated: true, completion: nil)
    }
    
    override func loadView() {
        view = findFriendsView
        adjustInsetsForScrollView(findFriendsView.tableView)
    }
}
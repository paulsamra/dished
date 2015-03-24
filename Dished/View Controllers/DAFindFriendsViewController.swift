//
//  DAFindFriendsViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit
import MessageUI

class DAFindFriendsViewController: DAViewController, UITableViewDelegate, UITableViewDataSource, DAFindFriendsDataSourceDelegate, MFMessageComposeViewControllerDelegate
{
    var findFriendsView = DAFindFriendsView()
    var friendsDataSource = DAFindFriendsDataSource()
    let cellIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findFriendsView.tableView.registerClass(DAUserTableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        
        findFriendsView.tableView.delegate = self
        findFriendsView.tableView.dataSource = self
        friendsDataSource.delegate = self
        
        navigationItem.title = "Find Friends"
        
        loadContacts()
    }
    
    private func loadContacts() {
        findFriendsView.showSpinner()
        friendsDataSource.loadFriends()
    }
    
    func findFriendsDataSourceDidFailToLoadFriends(dataSource: DAFindFriendsDataSource) {
        findFriendsView.hideSpinner()
        
        if friendsDataSource.contactsAccessAllowed() {
            findFriendsView.showErrorWithMessage("Failed to load contacts.")
        }
        else {
            findFriendsView.showErrorWithMessage("Dished needs your permission\nto access your contacts.")
        }
    }
    
    func findFriendsDataSourceDidFinishLoadingFriends(dataSource: DAFindFriendsDataSource) {
        findFriendsView.tableView.reloadData()
        findFriendsView.hideSpinner()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsDataSource.friends.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as DAUserTableViewCell
        
        let friend = friendsDataSource.friends[indexPath.row]
        
        cell.nameLabel.text = friend.name
        cell.sideButton.addTarget(self, action: "sideButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if friend.registered {
            cell.style = DAUserTableViewCellStyle.UsernameSubtitle
            cell.subtitleLabel?.text = friend.formattedUsername()
            let buttonTitle = friend.following ? "Unfollow" : "Follow"
            let buttonColor = friend.following ? UIColor.redColor() : UIColor.followButtonColor()
            cell.sideButton.setTitle(buttonTitle, forState: UIControlState.Normal)
            cell.sideButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
        }
        else {
            cell.style = DAUserTableViewCellStyle.ContactSubtitle
            cell.subtitleLabel?.text = friend.formattedPhoneNumber()
            let buttonTitle = friend.invited ? "Invited" : "Invite"
            let buttonColor = friend.invited ? UIColor.dishedColor() : UIColor.followButtonColor()
            cell.sideButton.setTitle(buttonTitle, forState: UIControlState.Normal)
            cell.sideButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func sideButtonPressed(button: UIButton) {
        let tableView = findFriendsView.tableView
        var buttonPosition: CGPoint = button.convertPoint(CGPointZero, toView: tableView)
        var indexPath: NSIndexPath = tableView.indexPathForRowAtPoint(buttonPosition)!
        let friend = friendsDataSource.friends[indexPath.row]
        
        if friend.registered {
            
        }
        else if !friend.invited {
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
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult)
    {
        switch result.value {
        case MessageComposeResultFailed.value: break
        case MessageComposeResultCancelled.value: break
        case MessageComposeResultSent.value: break
        default: break
        }
    }
    
    override func loadView() {
        view = findFriendsView
        adjustInsetsForScrollView(findFriendsView.tableView)
    }
}
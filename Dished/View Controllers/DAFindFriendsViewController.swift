//
//  DAFindFriendsViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit
import MessageUI

class DAFindFriendsViewController: DAViewController, UITableViewDelegate, UITableViewDataSource, DAFindFriendsDataSourceDelegate, DAFindFriendsInteractorDelegate {
    
    let findFriendsView = DAFindFriendsView()
    let friendsDataSource = DAFindFriendsDataSource()
    let cellIdentifier = "cell"
    
    lazy var findFriendsInteractor: DAFindFriendsInteractor = {
        return DAFindFriendsInteractor(delegate: self)
    }()
    
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
        friendsDataSource.loadData()
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
        cell.sideButton.addTarget(self, action: "cellButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if friend.registered {
            cell.style = DAUserTableViewCellStyle.UsernameSubtitle
            cell.subtitleLabel?.text = friend.formattedUsername()
            let buttonTitle = friend.following ? "Unfollow" : "Follow"
            let buttonColor = friend.following ? UIColor.redColor() : UIColor.followButtonColor()
            cell.sideButton.setTitle(buttonTitle, forState: UIControlState.Normal)
            cell.sideButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
            
            let url = NSURL(string: friend.image)
            let placeholder = UIImage(named: "profile_image")
            cell.userImageView?.sd_setImageWithURL(url, placeholderImage: placeholder)
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
    
    func cellButtonPressed(button: UIButton) {
        let indexPath = findFriendsView.tableView.indexPathForView(button)
        if indexPath == nil {
            return
        }
        
        let friend = friendsDataSource.friends[indexPath!.row]
        
        if friend.registered {
            findFriendsInteractor.doFollowInteractionForFriend(friend)
            findFriendsView.tableView.reloadData()
        }
        else if !friend.invited {
            if let composer = findFriendsInteractor.messageComposerForFriend(friend) {
                presentViewController(composer, animated: true, completion: nil)
            }
        }
    }
    
    func findFriendsInteractorDidFinishSendingMessage(interactor: DAFindFriendsInteractor) {
        dismissViewControllerAnimated(true, completion: nil)
        findFriendsView.tableView.reloadData()
    }
    
    override func loadView() {
        view = findFriendsView
        adjustInsetsForScrollView(findFriendsView.tableView)
    }
}
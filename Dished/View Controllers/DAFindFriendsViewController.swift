//
//  DAFindFriendsViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit
import MessageUI

class DAFindFriendsViewController: DAViewController, UITableViewDelegate, UITableViewDataSource, DADataSourceDelegate, DAFindFriendsInteractorDelegate {
    
    let findFriendsView = DAFindFriendsView()
    let cellIdentifier = "cell"
        
    lazy var findFriendsInteractor: DAFindFriendsInteractor = {
        return DAFindFriendsInteractor(delegate: self)
    }()
    
    lazy var friendsDataSource: DAFindFriendsDataSource = {
        return DAFindFriendsDataSource(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findFriendsView.tableView.registerClass(DAUserTableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        findFriendsView.tableView.delegate = self
        findFriendsView.tableView.dataSource = self
        
        navigationItem.title = "Find Friends"
        
        loadContacts()
    }
    
    private func loadContacts() {
        findFriendsView.showSpinner()
        friendsDataSource.loadData()
    }
    
    deinit {
        friendsDataSource.cancelLoadingData()
    }
    
    func dataSourceDidFailToLoadData(dataSource: DADataSource, withError error: NSError?) {
        findFriendsView.hideSpinner()
        
        if friendsDataSource.contactsAccessAllowed() {
            findFriendsView.showErrorWithMessage("Failed to load contacts.")
        }
        else {
            findFriendsView.showErrorWithMessage("Dished needs your permission\nto access your contacts.")
        }
    }
    
    func dataSourceDidFinishLoadingData(dataSource: DADataSource) {
        findFriendsView.tableView.reloadData()
        findFriendsView.hideSpinner()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsDataSource.friends.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as DAUserTableViewCell
        
        let friend = friendsDataSource.friends[indexPath.row]
        cell.configureWithFriend(friend)
        cell.sideButton.addTarget(self, action: "cellButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func cellButtonPressed(button: UIButton) {
        if let indexPath = findFriendsView.tableView.indexPathForView(button) {
            let friend = friendsDataSource.friends[indexPath.row]
            
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
    }
    
    func findFriendsInteractorDidFinishSendingMessage(interactor: DAFindFriendsInteractor) {
        dismissViewControllerAnimated(true, completion: nil)
        findFriendsView.tableView.reloadData()
    }
    
    override func loadView() {
        view = findFriendsView
    }
}
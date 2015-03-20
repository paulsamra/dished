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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsController.getFriends({
            success in
            
            
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    override func loadView() {
        view = findFriendsView
        
        if navigationController?.navigationBar != nil {
            let navigationBarFrame = navigationController!.navigationBar.bounds
            let tableViewInset = UIApplication.sharedApplication().statusBarFrame.size.height + navigationBarFrame.size.height
            findFriendsView.tableView.contentInset = UIEdgeInsetsMake(tableViewInset, 0, 0, 0)
        }
    }
}
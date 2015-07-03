//
//  DAMenuViewController2.swift
//  Dished
//
//  Created by Ryan Khalili on 4/17/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAMenuViewController: DAViewController, UITableViewDelegate, UITableViewDataSource, DAMenuTableViewDelegate {

    var menuView = DAMenuView()
    
    let cellIdentifier = "menuCell"
    let rowTitles = [
        "Find Friends",
        "Settings",
        "FAQs",
        "Terms & Conditions",
        "Privacy Policy",
        "Help"
    ]
    
    private var initialViewAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuView.tableView.delegate = self
        menuView.tableView.dataSource = self
        menuView.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        setupUserInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if !initialViewAppear && containerViewController().menuShowing() {
            containerViewController().slideOutMenu()
        }
        
        initialViewAppear = false
        
        menuView.tableView.deselectSelectedIndexPath()
        
        transitionCoordinator()?.notifyWhenInteractionEndsUsingBlock({
            handler in
            
            if handler.isCancelled() {
                let selectedIndexPath = self.menuView.tableView.indexPathForSelectedRow()
                self.menuView.tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                self.containerViewController().moveToMenu()
            }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupUserInfo() {
        let imageURL = NSURL(string: DAUserManager.sharedManager().img_thumb)
        menuView.tableView.userImageView.sd_setImageWithURL(imageURL, placeholderImage: UIImage(named: "profile_image"))
        
        if DAUserManager.sharedManager().username != nil {
            let username = "@\(DAUserManager.sharedManager().username)"
            menuView.tableView.usernameButton.setTitle(username, forState: UIControlState.Normal)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        
        cell.textLabel?.text = rowTitles[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        containerViewController().moveToMenu()
        
        switch(indexPath.row) {
            case 0: pushGetSocialView()
            case 1: pushSettingsView()
            case 2: goToDocumentViewWithName("FAQ")
            case 3: goToDocumentViewWithName(kTermsAndConditions)
            case 4: goToDocumentViewWithName(kPrivacyPolicy)
            case 5: UserVoice.presentUserVoiceContactUsFormForParentViewController(self)
            default: menuView.tableView.deselectSelectedIndexPath()
        }
    }
    
    private func pushGetSocialView() {
        let getSocialViewController = DAGetSocialViewController()
        navigationController?.pushViewController(getSocialViewController, animated: true)
    }
    
    private func goToDocumentViewWithName(name: String) {
        if let filePath = NSBundle.mainBundle().pathForResource(name, ofType: "html") {
            let documentViewController = DADocViewController(filePath: filePath, title: name)
            navigationController?.pushViewController(documentViewController, animated: true)
        }
    }
    
    func goToUserProfile() {
        containerViewController().moveToMenu()
        pushUserProfileWithUsername(DAUserManager.sharedManager().username)
    }
    
    func userImageTappedOnMenuTableView(menuTableView: DAMenuTableView) {
        goToUserProfile()
    }
    
    override func loadView() {
        view = menuView
        
        menuView.tableView.usernameButton.addTarget(self, action: "goToUserProfile", forControlEvents: UIControlEvents.TouchUpInside)
        menuView.tableView.viewProfileButton.addTarget(self, action: "goToUserProfile", forControlEvents: UIControlEvents.TouchUpInside)
        menuView.tableView.headerDelegate = self
    }
}
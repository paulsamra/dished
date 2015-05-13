//
//  DAShareLinkViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 5/10/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAShareLinkViewController: DAViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    let shareLinkView = DAShareLinkView()
    var socialMediaType: DASocialMediaType!
    
    private let cellIdentifier = "shareLinkCell"
    
    init?(socialMediaType: DASocialMediaType) {
        super.init(nibName: nil, bundle: nil)

        if !socialMediaType.configurable {
            return nil
        }
        
        self.socialMediaType = socialMediaType
        navigationItem.title = socialMediaType.name
    }

    required init(coder aDecoder: NSCoder) {
        self.socialMediaType = DASocialMediaType.Twitter
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shareLinkView.tableView.delegate = self
        shareLinkView.tableView.dataSource = self
        shareLinkView.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        
        cell.textLabel?.font = DAConstants.primaryFontWithSize(17.0)
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.textLabel?.textColor = socialMediaType.connected ? UIColor.redGradeColor() : UIColor.dishedColor()
        cell.textLabel?.text = socialMediaType.connected ? "Unlink" : "Link"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectSelectedIndexPath()
        
        if socialMediaType.connected {
            showVerifyDisconnectAlert()
        }
        else {
            shareLinkView.showSpinner()
            socialMediaType.connectWithCompletion({
                success in
                self.shareLinkView.hideSpinner()
                self.shareLinkView.tableView.reloadData()
            })
        }
    }
    
    private func showVerifyDisconnectAlert() {
        let title = "Are you sure you want to unlink your \(socialMediaType.name) account?"
        let alertView = UIAlertView(title: title, message: nil, delegate: self, cancelButtonTitle: "No")
        alertView.addButtonWithTitle("Yes")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            socialMediaType.disconnectWithCompletion({
                success in
                self.shareLinkView.tableView.reloadData()
            })
        }
    }
    
    override func loadView() {
        view = shareLinkView
    }
}
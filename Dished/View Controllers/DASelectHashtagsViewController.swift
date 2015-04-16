//
//  DASelectHashtagsViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 4/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

@objc protocol DASelectHashtagsViewControllerDelegate: class {
    func selectHashtagsViewControllerDidFinish(selectHashtagsViewController: DASelectHashtagsViewController)
}

class DASelectHashtagsViewController: DAViewController, UITableViewDelegate, UITableViewDataSource, DADataSourceDelegate, UITextFieldDelegate, DAHashtagInputTableViewCellDelegate {

    var selectHashtagsView: DASelectHashtagsView!
    var hashtagsDataSource: DASelectHashtagsDataSource
    
    weak var delegate: DASelectHashtagsViewControllerDelegate?
    
    private let hashtagCellIdentifier = "hashtagCell"
    private let hashtagInputCellIdentifier = "hashtagInputCell"
    private var hashtagsType: DASelectHashtagsType
    
    init(dataSource: DASelectHashtagsDataSource) {
        hashtagsDataSource = dataSource
        hashtagsType = dataSource.hashtagsType
        super.init(nibName: nil, bundle: nil)
        dataSource.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        hashtagsDataSource = DASelectHashtagsDataSource(hashtagsType: DASelectHashtagsType.Positive, dishType: DADishType.Food)
        hashtagsType = DASelectHashtagsType.Positive
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hashtagsDataSource.hashtagsType = hashtagsType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectHashtagsView.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: hashtagCellIdentifier)
        selectHashtagsView.tableView.registerClass(DAHashtagInputTableViewCell.self, forCellReuseIdentifier: hashtagInputCellIdentifier)
        selectHashtagsView.tableView.delegate = self
        selectHashtagsView.tableView.dataSource = self
        
        navigationItem.rightBarButtonItem?.enabled = false
        hashtagsDataSource.loadData()
    }
    
    func dataSourceDidFinishLoadingData(dataSource: DADataSource) {
        navigationItem.rightBarButtonItem?.enabled = true
        selectHashtagsView.tableView .reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func dataSourceDidFailToLoadData(dataSource: DADataSource, withError error: NSError?) {
        delegate?.selectHashtagsViewControllerDidFinish(self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = hashtagsDataSource.hashtags.count
        return count == 0 ? 1 : count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if hashtagsDataSource.hashtags.count == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(hashtagCellIdentifier) as! UITableViewCell
            cell.textLabel?.text = "Loading..."
            cell.accessoryView = selectHashtagsView.spinner
            cell.userInteractionEnabled = false
            selectHashtagsView.spinner.startAnimating()
        }
        else {
            if indexPath.row == 0 {
                let inputCell = tableView.dequeueReusableCellWithIdentifier(hashtagInputCellIdentifier) as! DAHashtagInputTableViewCell
                inputCell.selectionStyle = UITableViewCellSelectionStyle.None
                inputCell.delegate = self
                
                cell = inputCell
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier(hashtagCellIdentifier) as! UITableViewCell
                cell.accessoryView = nil
                cell.userInteractionEnabled = true
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                
                let hashtag = hashtagsDataSource.hashtags[indexPath.row - 1]
                cell.textLabel?.text = "#\(hashtag.name)"
                
                var selectionImage = hashtagsDataSource.hashtagIsSelected(hashtag) ? "hashtag_checked" : "hashtag_unchecked"
                cell.accessoryView = UIImageView(image: UIImage(named: selectionImage))
            }
        }
        
        cell.textLabel?.font = DAConstants.primaryFontWithSize(18.0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            return
        }
        
        let hashtag = hashtagsDataSource.hashtags[indexPath.row - 1]
        
        if hashtagsDataSource.hashtagIsSelected(hashtag) {
            hashtagsDataSource.deselectHashtag(hashtag)
        }
        else {
            hashtagsDataSource.selectHashtag(hashtag)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func hashtagInputTableViewCell(cell: DAHashtagInputTableViewCell, didAddHashtagWithName name: String) {
        let userHashtag = hashtagsDataSource.addUserDefinedHashtagWithName(name)
        hashtagsDataSource.selectHashtag(userHashtag)
        selectHashtagsView.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func barButtonPressed() {
        delegate?.selectHashtagsViewControllerDidFinish(self)
    }
    
    override func loadView() {
        selectHashtagsView = DASelectHashtagsView(hashtagsType: hashtagsDataSource.hashtagsType)
        view = selectHashtagsView
        
        var title: String
        let action = Selector("barButtonPressed")
        
        switch(hashtagsDataSource.hashtagsType) {
        case .Positive: title = "Next"
        case .Negative: title = "Done"
        }
        
        var button = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: action)
        navigationItem.rightBarButtonItem = button
        
        navigationItem.title = "#Tags"
    }
}
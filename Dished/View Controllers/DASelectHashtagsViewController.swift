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

class DASelectHashtagsViewController: DAViewController, UITableViewDelegate, UITableViewDataSource, DADataSourceDelegate {

    var selectHashtagsView: DASelectHashtagsView!
    var hashtagsDataSource: DASelectHashtagsDataSource
    
    weak var delegate: DASelectHashtagsViewControllerDelegate?
    
    private let hashtagCellIdentifier = "hashtagCell"
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
        return count == 0 ? 1 : count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(hashtagCellIdentifier) as! UITableViewCell
        
        cell.textLabel?.font = DAConstants.primaryFontWithSize(18.0)
        
        if hashtagsDataSource.hashtags.count == 0 {
            cell.textLabel?.text = "Loading..."
            cell.accessoryView = selectHashtagsView.spinner
            cell.userInteractionEnabled = false
            selectHashtagsView.spinner.startAnimating()
        }
        else {
            cell.accessoryView = nil
            cell.userInteractionEnabled = true
            
            let hashtag = hashtagsDataSource.hashtags[indexPath.row]
            cell.textLabel?.text = "#\(hashtag.name)"
            
            var selectionImage = hashtagsDataSource.hashtagIsSelected(hashtag) ? "hashtag_checked" : "hashtag_unchecked"
            cell.accessoryView = UIImageView(image: UIImage(named: selectionImage))
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hashtag = hashtagsDataSource.hashtags[indexPath.row]
        
        if hashtagsDataSource.hashtagIsSelected(hashtag) {
            hashtagsDataSource.deselectHashtag(hashtag)
        }
        else {
            hashtagsDataSource.selectHashtag(hashtag)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
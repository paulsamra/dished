//
//  DASelectHashtagsView.swift
//  Dished
//
//  Created by Ryan Khalili on 4/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DASelectHashtagsView: DAView {
    
    var tableView: UITableView!
    var nextBarButton: UIBarButtonItem!
    
    var hashtagsType = DASelectHashtagsType.Positive
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    private var tableHeaderTitle: String {
        get {
            switch(hashtagsType) {
            case .Positive: return "What did you like about the dish?"
            case .Negative: return "What didn't you like about the dish?"
            }
        }
    }
    
    init(hashtagsType: DASelectHashtagsType) {
        self.hashtagsType = hashtagsType
        super.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setupViews() {
        tableView = UITableView()
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        let label = UILabel()
        label.text = tableHeaderTitle
        label.font = DAConstants.primaryFontWithSize(17.0)
        label.textAlignment = NSTextAlignment.Center
        headerView.addSubview(label)
        label.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        var headerFrame = headerView.frame
        headerFrame.size.height = 50.0
        headerView.frame = headerFrame
        
        tableView.tableHeaderView = headerView
    }
}
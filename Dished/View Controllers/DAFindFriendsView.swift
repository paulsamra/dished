//
//  DAFindFriendsView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFindFriendsView: DAView {
    
    var tableView = UITableView()
    var errorLabel = UILabel()
    
    override func showSpinner() {
        super.showSpinner()
        tableView.hidden = true
        errorLabel.hidden = true
    }
    
    override func hideSpinner() {
        super.showSpinner()
        tableView.hidden = false
        errorLabel.hidden = false
    }
    
    override func setupViews() {
        super.setupViews()
        errorLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = NSTextAlignment.Center
        addSubview(errorLabel)
        errorLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
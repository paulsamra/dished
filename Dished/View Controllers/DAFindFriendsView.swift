//
//  DAFindFriendsView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFindFriendsView: DALoadingView {
    
    var tableView = UITableView()
    var errorLabel = UILabel()
    
    func showErrorWithMessage(message: String) {
        errorLabel.text = message
        tableView.hidden = true
        errorLabel.hidden = false
    }
    
    override func showSpinner() {
        super.showSpinner()
        tableView.hidden = true
        errorLabel.hidden = true
    }
    
    override func hideSpinner() {
        super.hideSpinner()
        tableView.hidden = false
        errorLabel.hidden = false
    }
    
    override func setupViews() {
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        errorLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = NSTextAlignment.Center
        addSubview(errorLabel)
        errorLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
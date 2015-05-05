//
//  DASettingsView.swift
//  Dished
//
//  Created by Ryan Khalili on 5/5/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DASettingsView: DAView {

    var tableView: UITableView!
    
    override func setupViews() {
        tableView = DATableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
//
//  DAMenuView.swift
//  Dished
//
//  Created by Ryan Khalili on 4/17/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAMenuView: DAView {

    var tableView: DAMenuTableView!

    override func setupViews() {
        tableView = DAMenuTableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
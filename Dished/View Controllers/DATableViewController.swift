//
//  DATableViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/27/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DATableViewController: DAViewController {
    
    var tableView: UITableView!
    
    override func loadView() {
        tableView = DATouchTableView()
        view = tableView
    }
}
//
//  DARegisterView.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

private let datePickerCellID = "datePickerCell"
private let textFieldCellID = "textFieldCell"
private let cellID = "cell"

class DARegisterView: DAView, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    
    var emailCell: UITableViewCell!
    var zipCodeCell: UITableViewCell!
    var lastNameCell: UITableViewCell!
    var usernameCell: UITableViewCell!
    var passwordCell: UITableViewCell!
    var firstNameCell: UITableViewCell!
    var birthdateCell: UITableViewCell!
    var phoneNumberCell: UITableViewCell!
    var confirmPasswordCell: UITableViewCell!
    
    var emailField: UITextField!
    var zipCodeField: UITextField!
    var lastNameField: UITextField!
    var usernameField: UITextField!
    var passwordField: UITextField!
    var firstNameField: UITextField!
    var phoneNumberField: UITextField!
    var confirmPasswordField: UITextField!
    
    private let rowTitles = [
        [
            "First Name",
            "Last Name"
        ], [
            "Username"
        ], [
            "Email"
        ], [
            "Phone Number",
            "Zip Code"
        ], [
            "Password",
            "Confirm Password"
        ], [
            "Date of Birth"
        ], [
            "Register"
        ]
    ]
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellID) as! UITableViewCell
        
//        switch(indexPath.section) {
//            case 0: cell = dequeueNameCellForRow(indexPath.row)
//            case 1: cell = dequeueUsernameCell()
//            case 2: cell = dequeueEmailCell()
//            case 3:
//            case 4:
//            case 5:
//            case 6:
//            case 7:
//            default: cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! DATableViewCell
//        }
        
        return cell
    }
    
    private func dequeueFirstNameCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellID) as! DATableViewCell
        cell.textLabel?.text = rowTitles[0][0]
        return cell
    }
    
    private func dequeueLastNameCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellID) as! DATableViewCell
        cell.textLabel?.text = rowTitles[0][1]
        return cell
    }
    
    private func dequeueUsernameCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellID) as! DATableViewCell
        cell.textLabel?.text = rowTitles[1][0]
        usernameCell = cell
        return cell
    }
    
    private func dequeueEmailCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellID) as! DATableViewCell
        cell.textLabel?.text = rowTitles[2][0]
        emailCell = cell
        return cell
    }
    
//    private func dequeuePhoneNumberCell() -> UITableViewCell {
//        
//    }
//    
//    private func dequeueZipCodeCell() -> UITableViewCell {
//        
//    }
    
    override func setupViews() {
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.registerClass(DADatePickerTableViewCell.self, forCellReuseIdentifier: "datePickerCell")
        tableView.registerClass(DATableViewCell.self, forCellReuseIdentifier: "textFieldCell")
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
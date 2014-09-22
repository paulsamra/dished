//
//  DADatePickerTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DADatePickerTableViewCell: UITableViewCell
{
    var datePicker: UIDatePicker!
    
    override init( style: UITableViewCellStyle, reuseIdentifier: String? )
    {
        super.init( style: style, reuseIdentifier: reuseIdentifier )
        setupDatePicker()
    }

    required init( coder aDecoder: NSCoder )
    {
        super.init( coder: aDecoder )
        setupDatePicker()
    }
    
    override init( frame: CGRect )
    {
        super.init( frame: frame )
        setupDatePicker()
    }
    
    func setupDatePicker()
    {
        let frame = CGRectMake( 0, -25, self.frame.size.width, 162 )
        datePicker = UIDatePicker( frame: frame )
        datePicker.datePickerMode = UIDatePickerMode.Date
        
        let dateComponents = NSDateComponents()
        dateComponents.year = 1990
        dateComponents.day = 15
        dateComponents.month = 6
        datePicker.date = NSCalendar.currentCalendar().dateFromComponents( dateComponents )!
        datePicker.maximumDate = NSDate()
        
        self.contentView.addSubview( datePicker )
    }
}
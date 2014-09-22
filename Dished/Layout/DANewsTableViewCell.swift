//
//  DANewsTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DANewsTableViewCell: UITableViewCell
{
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.layer.masksToBounds = true
    }
    
    class func newsLabelAttributes() -> NSDictionary
    {
        let font = UIFont( name: "HelveticaNeue-Light", size: 13.0 )
        
        return [ NSFontAttributeName : font ] as NSDictionary
    }
    
    class func timeLabelAttributes() -> NSDictionary
    {
        let font = UIFont( name: "HelveticaNeue-Light", size: 11.0 )
        
        return [ NSFontAttributeName : font ] as NSDictionary
    }
}
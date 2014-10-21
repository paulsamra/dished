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
    @IBOutlet weak var newsTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.layer.masksToBounds = true
        
        newsTextView.textContainerInset = UIEdgeInsetsZero
        newsTextView.userInteractionEnabled = false
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        userImageView.image = nil
        newsTextView.attributedText = nil
        newsTextView.text = nil
        timeLabel.attributedText = nil
        timeLabel.text = nil
    }
    
    class func newsLabelAttributes() -> NSDictionary
    {
        let font = UIFont( name: "HelveticaNeue-Light", size: 14.0 )
        let color = UIColor.blackColor()
        
        return NSDictionary( objectsAndKeys: font!, NSFontAttributeName, color, NSForegroundColorAttributeName )
    }
    
    class func timeLabelAttributes() -> NSDictionary
    {
        let font = UIFont( name: "HelveticaNeue-Light", size: 11.0 )
        
        return NSDictionary( objectsAndKeys: font!, NSFontAttributeName )
    }
}
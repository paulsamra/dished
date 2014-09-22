//
//  DACommentTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DACommentTableViewCell: SWTableViewCell
{
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = true;
        
        commentTextView.textContainerInset = UIEdgeInsetsZero
    }
}
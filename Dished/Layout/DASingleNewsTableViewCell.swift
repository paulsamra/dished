//
//  DANewsTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DASingleNewsTableViewCell: DANewsTableViewCell
{
    @IBOutlet weak var newsImageView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        newsImageView.layer.masksToBounds = true;
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        newsImageView.image = nil
    }
}
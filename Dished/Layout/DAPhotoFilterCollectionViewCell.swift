//
//  DAPhotoFilterCollectionViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 10/13/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DAPhotoFilterCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var photoImageView:    UIImageView!
    @IBOutlet weak var filterNameLabel:   UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        photoImageView.image = nil
        filterNameLabel.text = nil
        activityIndicator.stopAnimating()
    }
}
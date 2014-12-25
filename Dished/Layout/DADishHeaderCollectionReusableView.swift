//
//  DAReviewHeaderCollectionReusableView.swift
//  Dished
//
//  Created by Ryan Khalili on 12/25/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit


@objc protocol DADishHeaderCollectionReusableViewDelegate
{
    optional func titleButtonTappedOnFeedHeaderCollectionReusableView( cell: DADishHeaderCollectionReusableView )
}


class DADishHeaderCollectionReusableView: UICollectionReusableView
{
    weak var delegate: DADishHeaderCollectionReusableViewDelegate?
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var sideLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.75
        
        titleButton.addTarget( self, action: "titleButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
    }
    
    func titleButtonTapped()
    {
        delegate?.titleButtonTappedOnFeedHeaderCollectionReusableView?( self )
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        sideLabel.text = ""
        titleButton .setTitle( "", forState: UIControlState.Normal )
    }
}
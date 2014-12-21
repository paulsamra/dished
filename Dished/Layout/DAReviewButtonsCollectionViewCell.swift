//
//  DAReviewButtonsCollectionViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

@objc protocol DAReviewButtonsCollectionViewCellDelegate
{
    optional func commentsButtonTappedOnReviewButtonsCollectionViewCell( cell: DAReviewButtonsCollectionViewCell )
    optional func yumButtonTappedOnReviewButtonsCollectionViewCell( cell: DAReviewButtonsCollectionViewCell )
    optional func moreReviewsButtonTappedOnReviewButtonsCollectionViewCell( cell: DAReviewButtonsCollectionViewCell )
}

class DAReviewButtonsCollectionViewCell: UICollectionViewCell
{
    weak var delegate: DAReviewButtonsCollectionViewCellDelegate?
    
    @IBOutlet weak var yumButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var moreReviewsButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        yumButton.layer.cornerRadius = 2.0
        commentsButton.layer.cornerRadius = 2.0
        moreReviewsButton.layer.cornerRadius = 2.0
        
        commentsButton.titleLabel?.font = UIFont( name: kHelveticaNeueLightFont, size: 13.0 )
        
        yumButton.layer.masksToBounds = true
        commentsButton.layer.masksToBounds = true
        moreReviewsButton.layer.masksToBounds = true
        
        yumButton.addTarget( self, action: "yumButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
        commentsButton.addTarget( self, action: "commentsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
        moreReviewsButton.addTarget( self, action: "moreReviewsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
    }
    
    func yumButtonTapped()
    {
        delegate?.yumButtonTappedOnReviewButtonsCollectionViewCell?( self )
    }
    
    func commentsButtonTapped()
    {
        delegate?.commentsButtonTappedOnReviewButtonsCollectionViewCell?( self )
    }
    
    func moreReviewsButtonTapped()
    {
        delegate?.moreReviewsButtonTappedOnReviewButtonsCollectionViewCell?( self )
    }
}
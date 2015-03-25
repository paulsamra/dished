//
//  DAReviewButtonsCollectionViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

@objc protocol DAReviewButtonsCollectionViewCellDelegate {
    optional func commentsButtonTappedOnReviewButtonsCollectionViewCell( cell: DAReviewButtonsCollectionViewCell )
    optional func yumButtonTappedOnReviewButtonsCollectionViewCell( cell: DAReviewButtonsCollectionViewCell )
    optional func moreReviewsButtonTappedOnReviewButtonsCollectionViewCell( cell: DAReviewButtonsCollectionViewCell )
}

class DAReviewButtonsCollectionViewCell: DACollectionViewCell {
    
    weak var delegate: DAReviewButtonsCollectionViewCellDelegate?
    
    var yumButton: UIButton!
    var commentsButton: UIButton!
    var moreReviewsButton: UIButton!
    
    func yumButtonTapped() {
        delegate?.yumButtonTappedOnReviewButtonsCollectionViewCell?( self )
    }
    
    func commentsButtonTapped() {
        delegate?.commentsButtonTappedOnReviewButtonsCollectionViewCell?( self )
    }
    
    func moreReviewsButtonTapped() {
        delegate?.moreReviewsButtonTappedOnReviewButtonsCollectionViewCell?( self )
    }
    
    func setNumberOfComments(numberOfComments: Int) {
        var title = ""
        
        if numberOfComments == 0 {
            title = " No Comments"
        }
        else if numberOfComments == 1 {
            title = " \(numberOfComments) comment"
        }
        else {
            title = " \(numberOfComments) comments"
        }
        
        commentsButton.setTitle(title, forState: UIControlState.Normal)
    }
    
    func setYummed() {
        let yumIcon = UIImage(named: "yum_button")
        let backgroundColor = UIColor(r: 213, g: 24, b: 31, a: 255)
        let textColor = UIColor.whiteColor()
        
        yumButton.setImage(yumIcon, forState: UIControlState.Normal)
        yumButton.setBackgroundImage(UIImage.imageWithColor(backgroundColor), forState: UIControlState.Normal)
        yumButton.setTitleColor(textColor, forState: UIControlState.Normal)
    }
    
    func setUnyummed() {
        let unyumIcon = UIImage(named: "unyum_button")
        let backgroundColor = UIColor(r: 205, g: 209, b: 216, a: 255)
        let textColor = UIColor(r: 100, g: 104, b: 118, a: 255)
        
        yumButton.setImage(unyumIcon, forState: UIControlState.Normal)
        yumButton.setBackgroundImage(UIImage.imageWithColor(backgroundColor), forState: UIControlState.Normal)
        yumButton.setTitleColor(textColor, forState: UIControlState.Normal)
    }
    
    override func setupViews() {
        moreReviewsButton = grayButtonWithTitle("More Reviews", font: DAConstants.primaryFontWithSize(12.0))
        moreReviewsButton.addTarget( self, action: "moreReviewsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
        moreReviewsButton.contentEdgeInsets = UIEdgeInsetsMake(1.0, 0.0, 0.0, 0.0)
        addSubview(moreReviewsButton)
        moreReviewsButton.autoSetDimensionsToSize(CGSizeMake(90.0, 24.0))
        moreReviewsButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 5.0)
        moreReviewsButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 6.0)
        
        yumButton = grayButtonWithTitle("YUM", font: UIFont.systemFontOfSize(12.0))
        yumButton.addTarget( self, action: "yumButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
        yumButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, -2.0, 0.0, 0.0)
        yumButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 7.0, 0.0, 0.0)
        setUnyummed()
        addSubview(yumButton)
        yumButton.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 6.0)
        yumButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 5.0)
        yumButton.autoSetDimensionsToSize(CGSizeMake(61.0, 24.0))
        
        commentsButton = grayButtonWithTitle("7 Comments", font: DAConstants.primaryFontWithSize(13.0))
        commentsButton.addTarget( self, action: "commentsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
        commentsButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
        commentsButton.setImage(UIImage(named: "comments_button_icon"), forState: UIControlState.Normal)
        addSubview(commentsButton)
        commentsButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 5.0)
        commentsButton.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Trailing, ofView: yumButton, withOffset: 5.0)
        commentsButton.autoSetDimension(ALDimension.Height, toSize: 24.0)
        commentsButton.autoSetDimension(ALDimension.Width, toSize: 107.0, relation: NSLayoutRelation.GreaterThanOrEqual)
    }
    
    private func grayButtonWithTitle(title: String, font: UIFont) -> UIButton {
        let textColor = UIColor(r: 100, g: 104, b: 118, a: 255)
        let backgroundColor = UIColor(r: 205, g: 209, b: 216, a: 255)
        
        let button = UIButton()
        button.layer.cornerRadius = 2.0
        button.layer.masksToBounds = true
        button.setTitleColor(textColor, forState: UIControlState.Normal)
        button.titleLabel?.font = font
        button.setTitle(title, forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage.imageWithColor(backgroundColor), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        return button
    }
}
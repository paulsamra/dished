//
//  DAFoodieView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFoodieView: DAView {

    var userImageView: UIImageView!
    var usernameButton: UIButton!
    var followButton: UIButton!
    var descriptionLabel: UILabel!
    var reviewImageViews: [UIImageView]!
    
    override func setupViews() {
        userImageView = UIImageView()
        userImageView.contentMode = UIViewContentMode.ScaleAspectFill
        userImageView.clipsToBounds = true
        addSubview(userImageView)
        userImageView.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 10.0)
        userImageView.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 15.0)
        userImageView.autoSetDimensionsToSize(CGSizeMake(60.0, 60.0))
        
        followButton = UIButton()
        followButton.titleLabel?.font = DAConstants.primaryFontWithSize(17.0)
        followButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        addSubview(followButton)
        followButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 15.0)
        followButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 17.0)
        followButton.autoSetDimensionsToSize(CGSizeMake(63.0, 20.0))
        
        usernameButton = UIButton()
        usernameButton.titleLabel?.font = DAConstants.primaryFontWithSize(17.0)
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        addSubview(usernameButton)
        usernameButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 17.0)
        usernameButton.autoSetDimension(ALDimension.Height, toSize: 20.0)
        usernameButton.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Trailing, ofView: userImageView, withOffset: 8.0)
        usernameButton.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Leading, ofView: followButton, withOffset: 8.0)
        
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 2
        addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: usernameButton, withOffset: 4.0)
        descriptionLabel.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Trailing, ofView: userImageView, withOffset: 8.0)
        descriptionLabel.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: userImageView, withOffset: 2.0)
        descriptionLabel.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Trailing, ofView: followButton)
    }
}
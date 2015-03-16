//
//  DAFollowListTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DAUserListTableViewCell: DATableViewCell
{
    var userImageView: UIImageView!
    var usernameLabel: UILabel!
    var sideButton: UIButton!
    
    override func setupViews() {
        userImageView = UIImageView()
        userImageView.layer.masksToBounds = true
        let userImageSize = CGSizeMake(27.0, 27.0)
        userImageView.layer.cornerRadius = userImageSize.width / 2
        addSubview(userImageView)
        userImageView.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 15.0)
        userImageView.autoSetDimensionsToSize(userImageSize)
        userImageView.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        
        sideButton = UIButton()
        sideButton.titleLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        sideButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right;
        addSubview(sideButton)
        sideButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 8)
        sideButton.autoSetDimensionsToSize(CGSizeMake(64, 27))
        sideButton.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        
        usernameLabel = UILabel()
        usernameLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        addSubview(usernameLabel)
        usernameLabel.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        usernameLabel.autoSetDimension(ALDimension.Height, toSize: 21)
        usernameLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: userImageView, withOffset: 8)
        usernameLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: sideButton, withOffset: 7, relation: NSLayoutRelation.GreaterThanOrEqual)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.resetFields()
    }
    
    func resetFields()
    {
        userImageView.image = nil
        usernameLabel.text = ""
        sideButton.setTitle( "", forState: UIControlState.Normal )
    }
}
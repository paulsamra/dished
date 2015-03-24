//
//  DAFollowListTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

enum DAUserTableViewCellStyle {
    case Default
    case UsernameSubtitle
    case ContactSubtitle
}

class DAUserTableViewCell: DATableViewCell
{
    var userImageView: UIImageView?
    var nameLabel: UILabel!
    var sideButton: UIButton!
    var subtitleLabel: UILabel?
    
    private var nameLabelLeftConstraint: NSLayoutConstraint!
    private var nameLabelVerticalConstraint: NSLayoutConstraint!
    
    var style: DAUserTableViewCellStyle = DAUserTableViewCellStyle.Default {
        didSet {
            if oldValue != style {
                setNeedsLayout()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if style == DAUserTableViewCellStyle.Default {
            createImageView()
            subtitleLabel?.removeFromSuperview()
            subtitleLabel = nil
            
            removeConstraint(nameLabelLeftConstraint)
            nameLabelLeftConstraint = nameLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: userImageView!, withOffset: 8.0)
            
            nameLabelVerticalConstraint.constant = 0.0
            
            return
        }
        
        userImageView?.removeFromSuperview()
        userImageView = nil
        
        removeConstraint(nameLabelLeftConstraint)
        nameLabelLeftConstraint = nameLabel.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 15.0)
        
        createSubtitleLabel()
        nameLabelVerticalConstraint.constant = -9.0
    }
    
    private func createSubtitleLabel() {
        if subtitleLabel != nil {
            return
        }
        
        subtitleLabel = UILabel()
        subtitleLabel!.font = UIFont(name: kHelveticaNeueLightFont, size: 12.0)
        addSubview(subtitleLabel!)
        subtitleLabel!.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: nameLabel)
        subtitleLabel!.autoSetDimension(ALDimension.Height, toSize: 14.0)
        subtitleLabel!.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: sideButton, withOffset: 7.0, relation: NSLayoutRelation.GreaterThanOrEqual)
        subtitleLabel!.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: nameLabel, withOffset:2.0)
    }
    
    private func createImageView() {
        if userImageView != nil {
            return
        }
        
        userImageView = UIImageView()
        userImageView!.contentMode = UIViewContentMode.ScaleAspectFill
        userImageView!.layer.masksToBounds = true
        let userImageSize = CGSizeMake(27.0, 27.0)
        userImageView!.layer.cornerRadius = userImageSize.width / 2
        addSubview(userImageView!)
        userImageView!.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 15.0)
        userImageView!.autoSetDimensionsToSize(userImageSize)
        userImageView!.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
    }
    
    override func setupViews() {
        layer.masksToBounds = true
        
        createImageView()
        
        sideButton = UIButton()
        sideButton.titleLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        sideButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right;
        addSubview(sideButton)
        sideButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 8)
        sideButton.autoSetDimensionsToSize(CGSizeMake(64, 27))
        sideButton.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        addSubview(nameLabel)
        nameLabelVerticalConstraint = nameLabel.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        nameLabel.autoSetDimension(ALDimension.Height, toSize: 20.0)
        nameLabelLeftConstraint = nameLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: userImageView!, withOffset: 8)
        nameLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: sideButton, withOffset: 7, relation: NSLayoutRelation.GreaterThanOrEqual)
        
        createSubtitleLabel()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.resetFields()
    }
    
    func resetFields()
    {
        userImageView?.image = nil
        nameLabel.text = ""
        sideButton.setTitle( "", forState: UIControlState.Normal )
        subtitleLabel?.text = ""
    }
}
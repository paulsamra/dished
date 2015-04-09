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
    var userImageView: UIImageView!
    var nameLabel: UILabel!
    var sideButton: UIButton!
    var subtitleLabel: UILabel!
    
    let userImageSize = CGSizeMake(27.0, 27.0)
    
    private var nameLabelLeftConstraint: NSLayoutConstraint!
    private var nameLabelVerticalConstraint: NSLayoutConstraint!
    private var rightSideConstraint: NSLayoutConstraint!
    
    var style: DAUserTableViewCellStyle = DAUserTableViewCellStyle.Default {
        didSet {
            if oldValue != style {
                setNeedsLayout()
            }
        }
    }
    
    var showsSectionTitle: Bool = false {
        didSet {
            if oldValue != showsSectionTitle {
                setNeedsLayout()
            }
        }
    }
    
    func configureWithFriend(friend: DAFriend) {
        nameLabel.text = friend.name
        
        if friend.registered {
            style = DAUserTableViewCellStyle.UsernameSubtitle
            subtitleLabel?.text = friend.formattedUsername()
            let buttonTitle = friend.following ? "Unfollow" : "Follow"
            let buttonColor = friend.following ? UIColor.redColor() : UIColor.followButtonColor()
            sideButton.setTitle(buttonTitle, forState: UIControlState.Normal)
            sideButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
            
            let url = NSURL(string: friend.image)
            let placeholder = UIImage(named: "profile_image")
            userImageView?.sd_setImageWithURL(url, placeholderImage: placeholder)
            
            selectionStyle = UITableViewCellSelectionStyle.Default
        }
        else {
            style = DAUserTableViewCellStyle.ContactSubtitle
            subtitleLabel?.text = friend.formattedPhoneNumber()
            let buttonTitle = friend.invited ? "Invited" : "Invite"
            let buttonColor = friend.invited ? UIColor.dishedColor() : UIColor.followButtonColor()
            sideButton.setTitle(buttonTitle, forState: UIControlState.Normal)
            sideButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
            
            selectionStyle = UITableViewCellSelectionStyle.None
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let userImageSize = CGSizeMake(27.0, 27.0)
        userImageView.layer.cornerRadius = userImageSize.width / 2

        if style == DAUserTableViewCellStyle.Default || style == DAUserTableViewCellStyle.UsernameSubtitle {
            setupImageView()
            
            removeConstraint(nameLabelLeftConstraint)
            nameLabelLeftConstraint = nameLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: userImageView, withOffset: 8.0)
            
            nameLabelVerticalConstraint.constant = 0.0
        }
        else {
            userImageView?.removeFromSuperview()
            removeConstraint(nameLabelLeftConstraint)
            nameLabelLeftConstraint = nameLabel.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 15.0)
        }
        
        if style != DAUserTableViewCellStyle.Default {
            setupSubtitleLabel()
            nameLabelVerticalConstraint.constant = -9.0
        }
        else {
            subtitleLabel.removeFromSuperview()
        }
        
        rightSideConstraint.constant = showsSectionTitle ? -25.0 : -8.0
    }
    
    private func setupSubtitleLabel() {
        if subtitleLabel == nil {
            subtitleLabel = UILabel()
            subtitleLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 12.0)
        }
        
        addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: nameLabel)
        subtitleLabel.autoSetDimension(ALDimension.Height, toSize: 14.0)
        subtitleLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: sideButton, withOffset: 7.0, relation: NSLayoutRelation.GreaterThanOrEqual)
        subtitleLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: nameLabel, withOffset:2.0)
    }
    
    private func setupImageView() {
        if userImageView == nil {
            userImageView = UIImageView()
            userImageView.contentMode = UIViewContentMode.ScaleAspectFill
            userImageView.layer.masksToBounds = true
        }
        
        addSubview(userImageView)
        userImageView.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 15.0)
        userImageView.autoSetDimensionsToSize(userImageSize)
        userImageView.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
    }
    
    override func setupViews() {
        layer.masksToBounds = true
        
        setupImageView()
        
        sideButton = UIButton()
        sideButton.titleLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 18.0)
        sideButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right;
        addSubview(sideButton)
        rightSideConstraint = sideButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 8.0)
        sideButton.autoSetDimensionsToSize(CGSizeMake(70, 27))
        sideButton.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        addSubview(nameLabel)
        nameLabelVerticalConstraint = nameLabel.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        nameLabel.autoSetDimension(ALDimension.Height, toSize: 20.0)
        nameLabelLeftConstraint = nameLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: userImageView, withOffset: 8)
        nameLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: sideButton, withOffset: 7, relation: NSLayoutRelation.GreaterThanOrEqual)
        
        setupSubtitleLabel()
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
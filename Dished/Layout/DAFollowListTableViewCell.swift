//
//  DAFollowListTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit


@objc protocol DAFollowListTableViewCellDelegate
{
    optional func followButtonTappedOnFollowListTableViewCell( cell: DAFollowListTableViewCell )
}


class DAFollowListTableViewCell: UITableViewCell
{
    var delegate: DAFollowListTableViewCellDelegate?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = true;
                
        self.resetFields()
        
        followButton.addTarget( self, action: "followButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
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
        followButton.setTitle( "", forState: UIControlState.Normal )
    }
    
    func followButtonTapped()
    {
        delegate?.followButtonTappedOnFollowListTableViewCell?( self )
    }
}
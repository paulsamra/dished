//
//  DAFollowListTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit


@objc protocol DAUserListTableViewCellDelegate
{
    optional func sideButtonTappedOnFollowListTableViewCell( cell: DAUserListTableViewCell )
}


class DAUserListTableViewCell: UITableViewCell
{
    weak var delegate: DAUserListTableViewCellDelegate?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var sideButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
                
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = true;
                
        self.resetFields()
        
        sideButton.addTarget( self, action: "followButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
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
    
    func followButtonTapped()
    {
        delegate?.sideButtonTappedOnFollowListTableViewCell?( self )
    }
}
//
//  DAMenuTableView.swift
//  Dished
//
//  Created by Ryan Khalili on 5/5/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

protocol DAMenuTableViewDelegate: class {
    func userImageTappedOnMenuTableView(menuTableView: DAMenuTableView)
}

class DAMenuTableView: DATableView {
    
    var userImageView: UIImageView!
    var usernameButton: UIButton!
    var viewProfileButton: UIButton!
    private var userImageOutline: UIImageView!
    
    weak var headerDelegate: DAMenuTableViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
    }
    
    func userImageTapped() {
        headerDelegate?.userImageTappedOnMenuTableView(self)
    }
    
    override func setupViews() {
        let backgroundImage = UIImage(named: "menu_background")
        backgroundView = UIImageView(image: backgroundImage)
        
        let headerView = UIView(frame: CGRectMake(0, 0, 0, 300.0))
        userImageOutline = UIImageView(image: UIImage(named: "menu_image_outline"))
        headerView.addSubview(userImageOutline)
        
        userImageView = UIImageView()
        userImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userImageView.layer.borderWidth = 2.0
        userImageView.layer.masksToBounds = true
        userImageView.userInteractionEnabled = true
        userImageView.contentMode = UIViewContentMode.ScaleAspectFill
        headerView.addSubview(userImageView)
        
        usernameButton = UIButton()
        usernameButton.titleLabel?.font = UIFont.systemFontOfSize(20.0)
        usernameButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        headerView.addSubview(usernameButton)
        
        viewProfileButton = UIButton()
        viewProfileButton.titleLabel?.font = DAConstants.primaryFontWithSize(15.0)
        viewProfileButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        viewProfileButton.setTitle("visit your profile", forState: UIControlState.Normal)
        headerView.addSubview(viewProfileButton)
        
        tableHeaderView = headerView
        
        userImageOutline.autoSetDimensionsToSize(CGSizeMake(100.0, 100.0))
        userImageOutline.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        userImageOutline.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 55.0)
        
        userImageView.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Top, ofView: userImageOutline, withOffset: 7.0)
        userImageView.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: userImageOutline, withOffset: -7.0)
        userImageView.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Leading, ofView: userImageOutline, withOffset: 7.0)
        userImageView.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Trailing, ofView: userImageOutline, withOffset: -7.0)
        
        usernameButton.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        usernameButton.autoSetDimension(ALDimension.Height, toSize: 24.0)
        usernameButton.autoSetDimension(ALDimension.Width, toSize: 140.0, relation: NSLayoutRelation.GreaterThanOrEqual)
        usernameButton.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: userImageView, withOffset: 15.0)
        
        viewProfileButton.autoSetDimensionsToSize(CGSizeMake(140.0, 20.0))
        viewProfileButton.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        viewProfileButton.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: usernameButton, withOffset: 2.0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "userImageTapped")
        userImageView.addGestureRecognizer(tapGesture)
    }
}
//
//  DAGetSocialView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAGetSocialView: DAView {

    var tableView: UITableView!
    var skipButton: UIButton!
    
    override func setupViews() {
        tableView = DATouchTableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableView.tableHeaderView = tableHeaderView()
        tableView.tableFooterView = tableFooterView()
        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    private func tableHeaderView() -> UIView {
        let backgroundImage = UIImage(named: "get_social")!
        
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.clipsToBounds = true
        let imageSize = backgroundImage.size
        backgroundImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
        
        let dishLogo = UIImage(named: "dish_white")!
        let dishLogoView = UIImageView(image: dishLogo)
        dishLogoView.contentMode = UIViewContentMode.ScaleAspectFill
        dishLogoView.clipsToBounds = true
        backgroundImageView.addSubview(dishLogoView)
        let dishLogoSize = CGSizeMake(dishLogo.size.width / 2, dishLogo.size.height / 2)
        dishLogoView.autoSetDimensionsToSize(dishLogoSize)
        dishLogoView.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        dishLogoView.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: backgroundImageView, withOffset: -30.0)
        
        let label = UILabel()
        label.text = "The more friends you have joining you on this\nculinary journey, the better your\nrecommendations will be."
        label.textColor = UIColor.whiteColor()
        label.alpha = 0.7
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        label.numberOfLines = 3
        label.sizeToFit()
        backgroundImageView.addSubview(label)
        label.autoPinEdgeToSuperviewEdge(ALEdge.Left)
        label.autoPinEdgeToSuperviewEdge(ALEdge.Right)
        label.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: backgroundImageView, withOffset: 30)
        label.autoSetDimension(ALDimension.Height, toSize: label.frame.size.height)
        
        return backgroundImageView
    }
    
    private func tableFooterView() -> UIView {
        let footerView = UIView()
        footerView.clipsToBounds = true
        
        let label = UILabel()
        label.textColor = UIColor.grayColor()
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 5
        label.font = UIFont(name: "HelveticaNeue", size: 12.0)
        label.text = "Your contacts are periodically synced with Dished to\nallow you to find and follow friends. Don't worry,\nyou can disconnect at any time and your contact info\nwill be removed. We will never post to Facebook\nwithout your permission."
        label.sizeToFit()
        footerView.addSubview(label)
        label.autoPinEdgeToSuperviewEdge(ALEdge.Top)
        label.autoPinEdgeToSuperviewEdge(ALEdge.Left)
        label.autoPinEdgeToSuperviewEdge(ALEdge.Right)
        label.autoSetDimension(ALDimension.Height, toSize: label.frame.size.height)
        
        skipButton = UIButton()
        skipButton.setTitle("Skip", forState: UIControlState.Normal)
        skipButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18.0)
        skipButton.setTitleColor(UIColor.dishedColor(), forState: UIControlState.Normal)
        skipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        skipButton.sizeToFit()
        footerView.addSubview(skipButton)
        skipButton.autoPinEdgeToSuperviewEdge(ALEdge.Left)
        skipButton.autoPinEdgeToSuperviewEdge(ALEdge.Right)
        skipButton.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: label, withOffset: 10.0)
        skipButton.autoSetDimension(ALDimension.Height, toSize: skipButton.frame.size.height)
        
        let footerHeight = label.frame.size.height + 10.0 + skipButton.frame.size.height
        var footerFrame = footerView.frame
        footerFrame.size.height = footerHeight
        footerView.frame = footerFrame
        
        return footerView
    }
}
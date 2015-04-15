//
//  DAErrorView2.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAErrorView: DAView {

    var closeButton: UIButton!
    var messageLabel: UILabel!
    var tipLabel: UILabel!
    
    override func setupViews() {
        backgroundColor = UIColor(red: (218.0 / 255.0), green: 0, blue: 0, alpha: 1)
        
        closeButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        closeButton.setImage(UIImage(named: "error_close"), forState: UIControlState.Normal)
        addSubview(closeButton)
        closeButton.autoSetDimensionsToSize(CGSizeMake(30.0, 30.0))
        closeButton.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 6.0)
        closeButton.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 10.0)
        
        tipLabel = UILabel()
        tipLabel.font = UIFont.systemFontOfSize(12.0)
        tipLabel.textColor = UIColor.whiteColor()
        addSubview(tipLabel)
        tipLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 8.0)
        tipLabel.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 15.0)
        tipLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: closeButton, withOffset: 15.0)
        tipLabel.autoSetDimension(ALDimension.Height, toSize: 15.0)
        
        messageLabel = UILabel()
        messageLabel.font = UIFont.systemFontOfSize(16.0)
        messageLabel.textColor = UIColor.whiteColor()
        addSubview(messageLabel)
        messageLabel.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: tipLabel, withOffset: 2.0)
        messageLabel.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 15.0)
        messageLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: closeButton, withOffset: 15.0)
        messageLabel.autoSetDimension(ALDimension.Height, toSize: 20.0)
    }
}
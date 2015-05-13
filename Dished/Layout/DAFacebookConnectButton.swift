//
//  DAFacebookConnectButton.swift
//  Dished
//
//  Created by Ryan Khalili on 3/22/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFacebookConnectButton: UIButton {

    init() {
        super.init(frame: CGRectZero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        let blueBackgroundColor = UIColor(red: 0.16, green: 0.45, blue: 0.71, alpha: 1.0)
        let backgroundImage = UIImage.imageWithColor(blueBackgroundColor)
        
        setBackgroundImage(backgroundImage, forState: UIControlState.Normal)
        setTitle("Facebook Connect", forState: UIControlState.Normal)
        titleLabel?.font = UIFont(name: kHelveticaNeueLightFont, size: 23.0)
        setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
}
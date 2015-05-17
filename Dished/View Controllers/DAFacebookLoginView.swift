//
//  DAFacebookLoginView.swift
//  Dished
//
//  Created by Ryan Khalili on 5/13/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAFacebookLoginView: DAView {
    
    var facebookImageView: UIImageView!
    var spinner: UIActivityIndicatorView!
    
    override func setupViews() {
        backgroundColor = UIColor(r: 249, g: 249, b: 249, a: 255)
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        addSubview(spinner)
        spinner.autoCenterInSuperview()
        
        facebookImageView = UIImageView(image: UIImage(named: "facebook_login"))
        addSubview(facebookImageView)
        facebookImageView.autoSetDimensionsToSize(CGSizeMake(60.0, 60.0))
        facebookImageView.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        facebookImageView.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: spinner, withOffset: -30.0)
    }
}
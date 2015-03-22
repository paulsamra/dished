//
//  DALoadingView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoadingView: DAView {

    var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    func showSpinner() {
        spinner.startAnimating()
    }
    
    func hideSpinner() {
        spinner.stopAnimating()
    }
    
    override func setupViews() {
        backgroundColor = UIColor.whiteColor()
        
        spinner.hidesWhenStopped = true
        addSubview(spinner)
        spinner.autoCenterInSuperview()
        spinner.autoSetDimensionsToSize(spinner.bounds.size)
    }
}
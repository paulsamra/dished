//
//  DAView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAView: UIView {
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

    override init() {
        super.init()
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func showSpinner() {
        spinner.startAnimating()
    }
    
    func hideSpinner() {
        spinner.stopAnimating()
    }
    
    func setupViews() {
        spinner.hidesWhenStopped = true
        addSubview(spinner)
        spinner.autoCenterInSuperview()
        spinner.autoSetDimensionsToSize(spinner.bounds.size)
    }
}
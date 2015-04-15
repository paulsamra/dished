//
//  DALoadingView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DALoadingView: DAView {

    var spinner: UIActivityIndicatorView?

    private func newSpinner() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    private func layoutSpinner(spinner: UIActivityIndicatorView) {
        addSubview(spinner)
        spinner.autoCenterInSuperview()
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    func showSpinner() {
        spinner = newSpinner()
        layoutSpinner(spinner!)
        spinner?.startAnimating()
    }
    
    func hideSpinner() {
        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
    }
}
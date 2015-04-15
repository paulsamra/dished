//
//  DADocumentView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/18/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DADocumentView: DALoadingView {
    
    var webView = UIWebView()
    
    override func setupViews() {
        addSubview(webView)
        webView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
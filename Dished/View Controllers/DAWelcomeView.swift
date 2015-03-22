//
//  DAWelcomeView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAWelcomeView: DAView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var pageDotsImageView: UIImageView!
    
    override func setupViews() {
        scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        var contentWidth = CGFloat(0.0)
        
        for i in 0..<3 {
            var rect = CGRectZero
            rect.origin.x = frame.size.width * CGFloat(i);
            rect.origin.y = 0;
            rect.size.height = frame.size.height;
            rect.size.width = frame.size.width;
            contentWidth += rect.size.width
            
            let imageView = UIImageView(frame: rect)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.layer.masksToBounds = true
            
            let screenHeight = Int(UIScreen.mainScreen().bounds.size.height)
            let imageName = "welcome_\(i + 1)_\(screenHeight)"
            let image = UIImage(named: imageName)
            imageView.image = image
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSizeMake(contentWidth, frame.size.height)
    }
}
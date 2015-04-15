//
//  DAWelcomeView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

protocol DAWelcomeViewDelegate: class {
    func welcomeViewDidFinish(welcomeView: DAWelcomeView)
}

class DAWelcomeView: DAView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var pageImageView: UIImageView!
    
    weak var delegate: DAWelcomeViewDelegate?
    
    private var scrollViewSetup = false
    
    override func setupViews() {
        scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        pageImageView = UIImageView()
        let pageOneImage = UIImage(named: "page_1_dots")!
        pageImageView.image = pageOneImage
        addSubview(pageImageView)
        pageImageView.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 20.0)
        pageImageView.autoSetDimensionsToSize(pageOneImage.size)
        pageImageView.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !scrollViewSetup {
            scrollViewSetup = true
            var contentWidth = frame.size.width
            
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        let dotsImageName = "page_\(page + 1)_dots"
        let pageImage = UIImage(named: dotsImageName)
        pageImageView.image = pageImage
        
        checkCompletion()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        checkCompletion()
    }
    
    private func checkCompletion() {
        let threshold = frame.size.width * 3 - (frame.size.width / 2)
        let offset = scrollView.contentOffset.x
        
        if offset > threshold {
            var contentOffset = scrollView.contentOffset
            contentOffset.x = frame.size.width * 3
            UIView.animateWithDuration(0.1, animations: {
                self.scrollView.contentOffset = contentOffset
            },
            completion: {
                finished in
                self.hidden = true
                self.removeFromSuperview()
                self.delegate?.welcomeViewDidFinish(self)
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let threshold = frame.size.width * 2
        let offset = scrollView.contentOffset.x
        
        if offset > threshold {
            let percentage = (threshold - offset) / frame.size.width
            scrollView.alpha = 1 + percentage
        }
        else {
            scrollView.alpha = 1
        }
    }
}
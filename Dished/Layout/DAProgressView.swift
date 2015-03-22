//
//  DAProgressView2.swift
//  Dished
//
//  Created by Ryan Khalili on 3/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAProgressView: DAView {
    
    private var maskLayer: CALayer!
    private var grayDishLayer: CALayer!
    private var blueDishLayer: CALayer!

    override func setupViews() {
        setupImageLayer()
    }
    
    private func setupImageLayer() {
        grayDishLayer = CALayer()
        grayDishLayer.masksToBounds = true
        let dishImage = UIImage(named: "refresh_gray")!
        let x = (frame.size.width / 2) - (dishImage.size.width / 2)
        let y = (frame.size.height / 2) - (dishImage.size.height / 2)
        grayDishLayer.frame = CGRectMake(x, y, dishImage.size.width, dishImage.size.height)
        grayDishLayer.backgroundColor = UIColor.clearColor().CGColor
        grayDishLayer.contents = dishImage.CGImage
        layer.addSublayer(grayDishLayer)
        
        blueDishLayer = CALayer()
        blueDishLayer.frame = grayDishLayer.frame
        blueDishLayer.backgroundColor = UIColor.clearColor().CGColor
        blueDishLayer.contents = UIImage(named: "refresh_blue")!.CGImage
        layer.addSublayer(blueDishLayer)
        
        maskLayer = CALayer()
        maskLayer.anchorPoint = CGPointZero
        maskLayer.frame = CGRectMake(0, 0, 0, blueDishLayer.frame.size.height)
        maskLayer.backgroundColor = UIColor.blackColor().CGColor
        blueDishLayer.mask = maskLayer
    }
    
    func animateToPercentage(percentage: Float) {
        maskLayer.removeAllAnimations()
        
        if percentage.isNaN {
            return
        }
        
        let width = Float(blueDishLayer.frame.size.width) * percentage
        var maskFrame = maskLayer.frame
        maskFrame.size.width = CGFloat(width)
        
        if width.isNaN {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = maskLayer.frame.size.width
        animation.toValue = width
        animation.duration = 0.1
        maskLayer.frame = maskFrame
        maskLayer.addAnimation(animation, forKey: "progress")
    }
}
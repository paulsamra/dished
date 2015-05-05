//
//  DATableView.swift
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DATableView: UITableView
{
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    override func touchesBegan( touches: Set<NSObject>, withEvent event: UIEvent )
    {
        super.touchesBegan( touches as Set<NSObject>, withEvent: event )
        self.nextResponder()?.touchesBegan( touches as Set<NSObject>, withEvent: event )
    }
    
    override func touchesCancelled( touches: Set<NSObject>!, withEvent event: UIEvent! )
    {
        super.touchesCancelled( touches, withEvent: event )
        self.nextResponder()?.touchesCancelled( touches, withEvent: event )
    }
    
    override func touchesEnded( touches: Set<NSObject>, withEvent event: UIEvent )
    {
        super.touchesEnded( touches as Set<NSObject>, withEvent: event )
        self.nextResponder()?.touchesEnded( touches as Set<NSObject>, withEvent: event )
    }
    
    override func touchesMoved( touches: Set<NSObject>, withEvent event: UIEvent )
    {
        super.touchesMoved( touches as Set<NSObject>, withEvent: event )
        self.nextResponder()?.touchesMoved( touches as Set<NSObject>, withEvent: event )
    }
    
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool
    {
        return true;
    }
}
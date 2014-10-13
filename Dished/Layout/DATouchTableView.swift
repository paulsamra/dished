//
//  DATouchTableView.swift
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DATouchTableView: UITableView
{
    override func touchesBegan( touches: NSSet, withEvent event: UIEvent )
    {
        super.touchesBegan( touches, withEvent: event )
        self.nextResponder()?.touchesBegan( touches, withEvent: event )
    }
    
    override func touchesCancelled( touches: NSSet!, withEvent event: UIEvent! )
    {
        super.touchesCancelled( touches, withEvent: event )
        self.nextResponder()?.touchesCancelled( touches, withEvent: event )
    }
    
    override func touchesEnded( touches: NSSet, withEvent event: UIEvent )
    {
        super.touchesEnded( touches, withEvent: event )
        self.nextResponder()?.touchesEnded( touches, withEvent: event )
    }
    
    override func touchesMoved( touches: NSSet, withEvent event: UIEvent )
    {
        super.touchesMoved( touches, withEvent: event )
        self.nextResponder()?.touchesMoved( touches, withEvent: event )
    }
    
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool
    {
        return true;
    }
}
//
//  UITableView+Dished.swift
//  Dished
//
//  Created by Ryan Khalili on 3/24/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

extension UITableView {
    func deselectSelectedIndexPath() {
        if let indexPath = indexPathForSelectedRow() {
            deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func indexPathForView(view: UIView) -> NSIndexPath? {
        var buttonPosition: CGPoint = view.convertPoint(CGPointZero, toView: self)
        var indexPath: NSIndexPath? = indexPathForRowAtPoint(buttonPosition)
        return indexPath
    }
}
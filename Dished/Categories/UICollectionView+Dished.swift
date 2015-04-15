//
//  UICollectionView+ReloadAnimation.swift
//  Dished
//
//  Created by Ryan Khalili on 1/21/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation

extension UICollectionView {
    
    func indexPathForView(view: UIView) -> NSIndexPath? {
        var buttonPosition: CGPoint = view.convertPoint(CGPointZero, toView: self)
        var indexPath: NSIndexPath? = indexPathForItemAtPoint(buttonPosition)
        return indexPath
    }

    func reloadDataAnimated(animated: Bool) {
        if !animated {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        }
        
        self.reloadData()
        
        if !animated {
            CATransaction.commit()
        }
    }
    
    func reloadSections(sections: NSIndexSet, animated: Bool) {
        if !animated {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        }
        
        self.reloadSections( sections )
        
        if !animated {
            CATransaction.commit()
        }
    }
}
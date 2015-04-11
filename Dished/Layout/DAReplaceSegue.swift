//
//  DAReplaceSegue.swift
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DAReplaceSegue: UIStoryboardSegue
{
    override func perform()
    {
        let source = self.sourceViewController as! UIViewController
        let dest = self.destinationViewController as! UIViewController
        let navigationController = source.navigationController
        
        let controllerStack = navigationController?.viewControllers
        var stackCopy = NSMutableArray( array: controllerStack! )
        stackCopy.replaceObjectAtIndex( stackCopy.indexOfObject( source ), withObject: dest )
        navigationController?.setViewControllers( stackCopy as [AnyObject], animated: true )
    }
}
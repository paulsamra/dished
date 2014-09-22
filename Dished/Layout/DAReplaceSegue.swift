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
        let source = self.sourceViewController as UIViewController
        let dest = self.destinationViewController as UIViewController
        let navigationController = source.navigationController
        
        navigationController?.popToRootViewControllerAnimated( false )
        navigationController?.pushViewController( dest, animated: true )
    }
}
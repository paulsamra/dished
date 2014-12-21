//
//  NSAttributedString+Dished.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import Foundation

extension NSAttributedString
{
    class func linkedTextAttributesWithFontSize( fontSize: CGFloat ) -> NSDictionary
    {
        return [ NSForegroundColorAttributeName : UIColor.dishedColor(),
                            NSFontAttributeName : UIFont( name: kHelveticaNeueLightFont, size: fontSize )! ]
    }
}
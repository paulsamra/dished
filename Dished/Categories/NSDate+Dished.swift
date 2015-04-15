//
//  NSAttributedString+Dished.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import Foundation

extension NSDate
{
    func attributedTimeStringWithAttributes( attributes: [NSObject:AnyObject]? ) -> NSAttributedString
    {
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        let timeInterval = currentDate.timeIntervalSinceDate( self )
        var unit = ""
        var value = 0
        
        if timeInterval < 60
        {
            value = Int( timeInterval )
            unit = "s"
        }
        else if timeInterval < 3600
        {
            value = Int( timeInterval ) / 60
            unit = "m"
        }
        else if timeInterval < 86400
        {
            value = Int( timeInterval ) / 3600
            unit = "h"
        }
        else
        {
            let start = calendar.ordinalityOfUnit( NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.EraCalendarUnit, forDate: self )
            let end = calendar.ordinalityOfUnit( NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.EraCalendarUnit, forDate: currentDate )
            
            if timeInterval < 604800
            {
                value = end - start
                unit = "d"
            }
            else
            {
                value = ( end - start ) / 7
                unit = "w"
            }
        }
        
        let attributedTimeString = NSAttributedString( string: " \(value)" + unit, attributes: attributes )
        
        let clockAttachment = NSTextAttachment()
        clockAttachment.image = UIImage( named: "clock" )
        var clockString = NSAttributedString( attachment: clockAttachment ).mutableCopy() as! NSMutableAttributedString
        clockString.appendAttributedString( attributedTimeString )
        
        return clockString
    }
}
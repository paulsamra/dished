//
//  NSAttributedString+Dished.m
//  Dished
//
//  Created by Ryan Khalili on 9/14/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "NSAttributedString+Dished.h"


@implementation NSAttributedString (Dished)

+ (NSAttributedString *)attributedTimeStringWithDate:(NSDate *)date attributes:(NSDictionary *)attributes
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:date];
    
    NSString *format = nil;
    NSInteger value  = 0;
    
    if( timeInterval < 60 )
    {
        format = @"%lds";
        value = timeInterval;
    }
    else if( timeInterval < 3600 )
    {
        format = @"%ldm";
        value = timeInterval / 60;
    }
    else if( timeInterval < 86400 )
    {
        value = timeInterval / 3600;
        format = @"%ldh";
    }
    else
    {
        NSInteger start = [currentCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
        NSInteger end = [currentCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:currentDate];
        
        if( timeInterval < 604800 )
        {
            value = end - start;
            format = @"%ldd";
        }
        else
        {
            value = ( end - start ) / 7;
            format = @"%ldw";
        }
    }
    
    NSString *timeString = [NSString stringWithFormat:format, value];
    
    NSMutableAttributedString *attributedTimeString = [[NSMutableAttributedString alloc] initWithString:timeString attributes:attributes];
    
    [attributedTimeString insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
    
    NSTextAttachment *clockAttachment = [[NSTextAttachment alloc] init];
    clockAttachment.image = [UIImage imageNamed:@"clock"];
    NSMutableAttributedString *clockString = [[NSAttributedString attributedStringWithAttachment:clockAttachment] mutableCopy];
    
    [clockString appendAttributedString:attributedTimeString];
    
    return clockString;
}

+ (NSAttributedString *)attributedTimeStringWithDate:(NSDate *)date
{
    return [NSAttributedString attributedTimeStringWithDate:date attributes:nil];
}

@end
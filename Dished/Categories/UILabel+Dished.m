//
//  UILabel+Dished.m
//  Dished
//
//  Created by Ryan Khalili on 8/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "UILabel+Dished.h"


@implementation UILabel(Dished)

- (void)setAttributedTextForFeedItemDate:(NSDate *)date
{
    NSMutableAttributedString *timeString = [[NSMutableAttributedString alloc] initWithString:[self timeStringWithDate:date]];
    [timeString insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
    
    NSTextAttachment *clockAttachment = [[NSTextAttachment alloc] init];
    clockAttachment.image = [UIImage imageNamed:@"feed_time"];
    NSMutableAttributedString *clockString = [[NSAttributedString attributedStringWithAttachment:clockAttachment] mutableCopy];
    
    [clockString appendAttributedString:timeString];
    
    self.attributedText = clockString;
}

- (NSString *)timeStringWithDate:(NSDate *)date
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit;
    
    NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:date  toDate:[NSDate date]  options:0];
    
    NSString *format = nil;
    NSInteger value  = 0;
    
    if( timeInterval < 60 )
    {
        format = @"%lds";
        value = conversionInfo.second;
    }
    else if( timeInterval < 3600 )
    {
        format = @"%ldm";
        value = conversionInfo.minute;
    }
    else if( timeInterval < 86400 )
    {
        format = @"%ldh";
        value = conversionInfo.hour;
    }
    else if( timeInterval < 604800 )
    {
        format = @"%ldd";
        value = conversionInfo.day;
    }
    else
    {
        format = @"%ldw";
        value = conversionInfo.week;
    }
    
    return [NSString stringWithFormat:format, value];
}

@end
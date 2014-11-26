//
//  NSAttributedString+Dished.h
//  Dished
//
//  Created by Ryan Khalili on 9/14/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSAttributedString (Dished)

+ (NSDictionary *)linkedTextAttributesWithFontSize:(CGFloat)fontSize;
+ (NSAttributedString *)attributedTimeStringWithDate:(NSDate *)date;
+ (NSAttributedString *)attributedTimeStringWithDate:(NSDate *)date attributes:(NSDictionary *)attributes;

@end
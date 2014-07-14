//
//  DAReview.m
//  Dished
//
//  Created by Ryan Khalili on 7/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewReview.h"

@implementation DANewReview

- (id)init
{
    self = [super init];
    
    if( self )
    {
        _hashtags = [NSArray array];
        _type     = kFood;
        _image    = nil;
        _title    = @"";
        _comment  = @"";
        _price    = @"";
        _grade    = @"";
        _dishID   = @"";
        
        _locationName       = @"";
        _locationStreetNum  = @"";
        _locationStreetName = @"";
        _locationCity       = @"";
        _locationState      = @"";
        _locationZip        = @"";
        _locationPhone      = @"";
    }
    
    return self;
}

@end
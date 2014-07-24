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
        _title    = @"";
        _comment  = @"";
        _price    = @"";
        _rating   = @"";
        _dishID   = @"";
        
        _locationName       = @"";
        _locationID         = @"";
        _googleID           = @"";
        _locationStreetNum  = @"";
        _locationStreetName = @"";
        _locationCity       = @"";
        _locationState      = @"";
        _locationZip        = @"";
        _locationPhone      = @"";
        _locationLongitude  = 0;
        _locationLatitude   = 0;
    }
    
    return self;
}

@end
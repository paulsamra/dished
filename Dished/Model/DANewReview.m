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
        _dishID             = 0;
        _googleID           = 0;
        _locationID         = 0;
        _locationLongitude  = 0;
        _locationLatitude   = 0;
    }
    
    return self;
}

@end
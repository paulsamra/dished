//
//  DAGlobalReview.m
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGlobalReview.h"


@implementation DAGlobalReview

- (id)initWithData:(id)data
{
    if( self = [super initWithData:data] )
    {
        _source = nilOrJSONObjectForKey( data, @"source" );

        _review_id = [data[@"id"] integerValue];
    }
    
    return self;
}

@end
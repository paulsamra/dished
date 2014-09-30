//
//  DAExploreDishSearchResult.m
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreDishSearchResult.h"

@implementation DAExploreDishSearchResult

+ (DAExploreDishSearchResult *)dishSearchResultWithData:(id)data
{
    return [[DAExploreDishSearchResult alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        _name              = nilOrJSONObjectForKey( data, @"name" );
        _type              = nilOrJSONObjectForKey( data, @"type" );
        _price             = nilOrJSONObjectForKey( data, @"price" );
        _grade             = nilOrJSONObjectForKey( data, @"grade" );
        _imageURL          = nilOrJSONObjectForKey(data, @"img" );
        _locationName      = nilOrJSONObjectForKey( data[@"location"], @"name" );
        
        _dishID            = [data[@"id"] integerValue];
        _locationID        = [data[@"location"][@"id"] integerValue];
        _totalReviews      = [data[@"num_reviews"] integerValue];
        _friendReviews     = [data[@"num_reviews_friends"] integerValue];
        _influencerReviews = [data[@"num_reviews_influencers"] integerValue];
    }
    
    return self;
}

@end
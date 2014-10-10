//
//  DAExploreDishSearchResult.m
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADish.h"

@implementation DADish

+ (DADish *)dishWithData:(id)data
{
    return [[DADish alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        _name              = nilOrJSONObjectForKey( data, @"name" );
        _type              = nilOrJSONObjectForKey( data, @"type" );
        _price             = nilOrJSONObjectForKey( data, @"price" );
        _avg_grade         = nilOrJSONObjectForKey( data, @"avg_grade" );
        _grade             = nilOrJSONObjectForKey( data, @"grade" );
        _imageURL          = nilOrJSONObjectForKey( data, @"img_thumb" );
        _locationName      = nilOrJSONObjectForKey( data[@"location"], @"name" );
        
        _dishID            = [nilOrJSONObjectForKey( data, @"id" )                      integerValue];
        _numComments       = [nilOrJSONObjectForKey( data, @"num_comments" )            integerValue];
        _totalReviews      = [nilOrJSONObjectForKey( data, @"num_reviews" )             integerValue];
        _friendReviews     = [nilOrJSONObjectForKey( data, @"num_reviews_friends" )     integerValue];
        _influencerReviews = [nilOrJSONObjectForKey( data, @"num_reviews_influencers" ) integerValue];
        
        NSDictionary *location = nilOrJSONObjectForKey( data, @"location" );
        _longitude         = [nilOrJSONObjectForKey( location, @"longitude" ) doubleValue];
        _latitude          = [nilOrJSONObjectForKey( location, @"latitude" )  doubleValue];
        _locationID        = [nilOrJSONObjectForKey( location, @"id" )        integerValue];
    }
    
    return self;
}

@end
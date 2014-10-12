//
//  DAUserProfile.m
//  Dished
//
//  Created by Ryan Khalili on 10/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserProfile.h"


@implementation DAUserProfile

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        NSDictionary *user = nilOrJSONObjectForKey( data, @"user" );
        
        _desc      = nilOrJSONObjectForKey( user, @"desc" );
        _type      = nilOrJSONObjectForKey( user, @"type" );
        _username  = nilOrJSONObjectForKey( user, @"username" );
        _firstName = nilOrJSONObjectForKey( user, @"fname" );
        _lastName  = nilOrJSONObjectForKey( user, @"lname" );
        _img_thumb = nilOrJSONObjectForKey( user, @"img_thumb" );
        
        _user_id       = [nilOrJSONObjectForKey( user, @"id" )            integerValue];
        _num_reviews   = [nilOrJSONObjectForKey( data, @"num_reviews" )   integerValue];
        _num_following = [nilOrJSONObjectForKey( data, @"num_following" ) integerValue];
        _num_followers = [nilOrJSONObjectForKey( data, @"num_followers" ) integerValue];
        
        _caller_follows   = [nilOrJSONObjectForKey( data, @"caller_follows" )   boolValue];
        _is_profile_owner = [nilOrJSONObjectForKey( data, @"is_profile_owner" ) boolValue];
        
        NSDictionary *reviews = nilOrJSONObjectForKey( data, @"reviews" );
        _foodReviews     = [self reviewsWithData:nilOrJSONObjectForKey( reviews, kFood )];
        _wineReviews     = [self reviewsWithData:nilOrJSONObjectForKey( reviews, kWine )];
        _cocktailReviews = [self reviewsWithData:nilOrJSONObjectForKey( reviews, kCocktail )];
    }
    
    return self;
}

- (NSArray *)reviewsWithData:(id)data
{
    NSMutableArray *reviews = [NSMutableArray array];
    
    for( NSDictionary *review in data )
    {
        [reviews addObject:[DADish dishWithData:review]];
    }
    
    return reviews;
}

@end
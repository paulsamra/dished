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
        NSDictionary *user = nilOrJSONObjectForKey( data, kUserKey );
        if( user )
        {
            _desc      = nilOrJSONObjectForKey( user, @"desc" );
            _type      = nilOrJSONObjectForKey( user, kTypeKey );
            _username  = nilOrJSONObjectForKey( user, kUsernameKey );
            _firstName = nilOrJSONObjectForKey( user, @"fname" );
            _lastName  = nilOrJSONObjectForKey( user, @"lname" );
            _img_thumb = nilOrJSONObjectForKey( user, kImgThumbKey );
            _user_id       = [nilOrJSONObjectForKey( user, kIDKey ) integerValue];
        }
        
        _num_reviews   = [nilOrJSONObjectForKey( data, @"num_reviews" )   integerValue];
        _num_following = [nilOrJSONObjectForKey( data, @"num_following" ) integerValue];
        _num_followers = [nilOrJSONObjectForKey( data, @"num_followers" ) integerValue];
        
        _is_private       = [nilOrJSONObjectForKey( data, @"is_private" )       boolValue];
        _caller_follows   = [nilOrJSONObjectForKey( data, @"caller_follows" )   boolValue];
        _is_profile_owner = [nilOrJSONObjectForKey( data, @"is_profile_owner" ) boolValue];
        
        NSDictionary *reviews = nilOrJSONObjectForKey( data, kReviewsKey );
        if( reviews )
        {
            _foodReviews     = [self reviewsWithData:nilOrJSONObjectForKey( reviews, kFood )];
            _wineReviews     = [self reviewsWithData:nilOrJSONObjectForKey( reviews, kWine )];
            _cocktailReviews = [self reviewsWithData:nilOrJSONObjectForKey( reviews, kCocktail )];
        }
    }
    
    return self;
}

- (NSArray *)reviewsWithData:(id)data
{
    NSMutableArray *reviews = [NSMutableArray array];
    
    for( NSDictionary *review in data )
    {
        [reviews addObject:[DAReview reviewWithData:review]];
    }
    
    return reviews;
}

- (void)addFoodReviewsWithData:(id)data
{
    self.foodReviews = [self.foodReviews arrayByAddingObjectsFromArray:[self reviewsWithData:data]];
}

- (void)addCocktailReviewsWithData:(id)data
{
    self.cocktailReviews = [self.cocktailReviews arrayByAddingObjectsFromArray:[self reviewsWithData:data]];
}

- (void)addWineReviewsWithData:(id)data
{
    self.wineReviews = [self.wineReviews arrayByAddingObjectsFromArray:[self reviewsWithData:data]];
}

@end
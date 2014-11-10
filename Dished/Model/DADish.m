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
        _name              = nilOrJSONObjectForKey( data, kNameKey );
        _type              = nilOrJSONObjectForKey( data, kTypeKey );
        _price             = nilOrJSONObjectForKey( data, kPriceKey );
        _avg_grade         = nilOrJSONObjectForKey( data, @"avg_grade" );
        _grade             = nilOrJSONObjectForKey( data, kGradeKey );
        _imageURL          = nilOrJSONObjectForKey( data, kImgThumbKey );
        
        _dishID            = [nilOrJSONObjectForKey( data, kIDKey )                     integerValue];
        _totalReviews      = [nilOrJSONObjectForKey( data, @"num_reviews" )             integerValue];
        _friendReviews     = [nilOrJSONObjectForKey( data, @"num_reviews_friends" )     integerValue];
        _influencerReviews = [nilOrJSONObjectForKey( data, @"num_reviews_influencers" ) integerValue];
        
        NSDictionary *location = nilOrJSONObjectForKey( data, kLocationKey );
        if( location )
        {
            _locationName      = nilOrJSONObjectForKey( location, kNameKey );
            
            _longitude         = [nilOrJSONObjectForKey( location, kLongitudeKey ) doubleValue];
            _latitude          = [nilOrJSONObjectForKey( location, kLatitudeKey )  doubleValue];
            _locationID        = [nilOrJSONObjectForKey( location, kIDKey )        integerValue];
        }
    }
    
    return self;
}

@end
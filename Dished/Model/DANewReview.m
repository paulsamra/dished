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

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[kCommentKey] = self.comment;
    dict[kGradeKey]   = self.rating;
    
    if( self.price && self.price.length > 0 )
    {
        if( [self.price characterAtIndex:0] == '$' )
        {
            self.price = [self.price substringFromIndex:1];
        }
        
        dict[kPriceKey] = self.price;
    }
    
    NSString *hashtagString = @"";
    for( DAHashtag *hashtag in self.hashtags )
    {
        if( hashtag.userDefined )
        {
            hashtagString = [hashtagString stringByAppendingFormat:@"user#%@,", hashtag.name];
        }
        else
        {
            hashtagString = [hashtagString stringByAppendingFormat:@"%d,", (int)hashtag.hashtag_id];
        }
    }
    
    if( hashtagString.length > 0 )
    {
        hashtagString = [hashtagString substringToIndex:hashtagString.length - 1];
        dict[kHashtagsKey] = hashtagString;
    }
    
    if( self.dishID != 0 )
    {
        dict[@"dish_id"] = @(self.dishID);
    }
    else if( self.locationID != 0 || self.googleID != 0 )
    {
        if( self.locationID != 0 )
        {
            dict[kLocationIDKey] = @(self.locationID);
        }
        else if( self.googleID )
        {
            dict[@"loc_google_id"] = self.googleID;
        }
        
        dict[kTypeKey] = self.type;
        dict[@"title"] = self.title;
    }
    else
    {
        dict[kLocationNameKey]     = self.locationName;
        dict[@"loc_longitude"]     = @(self.locationLongitude);
        dict[@"loc_latitude"]      = @(self.locationLatitude);
        dict[@"loc_street_number"] = self.locationStreetNum;
        dict[@"loc_street"]        = self.locationStreetName;
        dict[@"loc_city"]          = self.locationCity;
        dict[@"loc_state"]         = self.locationState;
        dict[@"loc_zip"]           = self.locationZip;
        
        dict[kTypeKey] = self.type;
        dict[@"title"] = self.title;
    }
    
    return dict;
}

@end
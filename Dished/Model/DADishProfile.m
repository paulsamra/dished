//
//  DADishProfile.m
//  Dished
//
//  Created by Ryan Khalili on 9/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADishProfile.h"

@implementation DADishProfile

+ (DADishProfile *)profileWithData:(id)data
{
    DADishProfile *profile = [[DADishProfile alloc] init];
    
    profile.name            = nilOrJSONObjectForKey( data, kNameKey );
    profile.desc            = nilOrJSONObjectForKey( data, @"desc" );
    profile.price           = nilOrJSONObjectForKey( data, kPriceKey );
    profile.type            = nilOrJSONObjectForKey( data, kTypeKey );
    profile.loc_name        = nilOrJSONObjectForKey( data, kLocationNameKey );
    profile.grade           = nilOrJSONObjectForKey( data, kGradeKey );
    profile.images          = nilOrJSONObjectForKey( data, kImagesKey );
    profile.num_grades      = nilOrJSONObjectForKey( data, @"num_grades" );
    
    profile.dish_id         = [nilOrJSONObjectForKey( data, kIDKey )         integerValue];
    profile.loc_id          = [nilOrJSONObjectForKey( data, kLocationIDKey ) integerValue];
    profile.num_yums        = [data[@"num_yums"]   integerValue];
    profile.num_images      = [data[@"num_images"] integerValue];
    
    profile.additional_info = [data[@"additional_info"] boolValue];
        
    NSArray *reviews = nilOrJSONObjectForKey( data, kReviewsKey );
    if( reviews )
    {
        NSMutableArray *newReviews = [NSMutableArray array];
        
        for( NSDictionary *review in reviews )
        {
            [newReviews addObject:[[DAGlobalReview alloc] initWithData:review]];
        }
        
        profile.reviews = newReviews;
    }
    
    return profile;
}

@end
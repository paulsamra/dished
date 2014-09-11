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
    
    profile.dish_id         = [data[@"id"] integerValue];
    profile.name            = data[@"name"];
    profile.desc            = nilOrJSONObjectForKey( data, @"desc" );
    profile.price           = nilOrJSONObjectForKey( data, @"price" );
    profile.loc_id          = [data[@"loc_id"] integerValue];
    profile.loc_name        = nilOrJSONObjectForKey( data, @"loc_name" );
    profile.additional_info = [data[@"additional_info"] boolValue];
    profile.num_yums        = [data[@"num_yums"] integerValue];
    profile.grade           = nilOrJSONObjectForKey( data, @"grade" );
    profile.num_images      = [data[@"num_images"] integerValue];
    profile.images          = nilOrJSONObjectForKey( data, @"images" );
    profile.dish_id         = [data[@"dish_id"] integerValue];
    
    NSArray *reviews = nilOrJSONObjectForKey( data, @"reviews" );
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
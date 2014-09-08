//
//  DAReview.m
//  Dished
//
//  Created by Ryan Khalili on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReview.h"
#import "DAUsername.h"


@implementation DAReview

+ (DAReview *)reviewWithData:(id)data
{
    DAReview *review = [[DAReview alloc] init];
    
    review.name              = data[@"name"];
    review.creator_id        = [data[@"creator_id"] integerValue];
    review.creator_username  = data[@"creator_username"];
    review.creator_img_thumb = data[@"creator_img_thumb"];
    review.creator_type      = data[@"creator_type"];
    review.grade             = data[@"grade"];
    review.comment           = data[@"comment"];
    review.price             = data[@"price"];
    review.img               = data[@"img"];
    review.loc_id            = [data[@"loc_id"] integerValue];
    review.loc_name          = data[@"loc_name"];
    
    NSArray *yums = nilOrJSONObjectForKey( data, @"yums" );
    if( yums && [yums isKindOfClass:[NSArray class]] )
    {
        NSMutableArray *newYums = [NSMutableArray array];
        
        for( NSDictionary *yum in yums )
        {
            [newYums addObject:[DAUsername usernameWithData:yum]];
        }
        
        review.yums = [newYums copy];
    }
    else if( yums && [yums isKindOfClass:[NSDictionary class]] )
    {
        review.yums = [NSArray arrayWithObjects:[DAUsername usernameWithData:yums], nil];
    }
    
    NSArray *comments = nilOrJSONObjectForKey( data, @"comments" );
    if( comments )
    {
        NSMutableArray *newComments = [NSMutableArray array];
        
        for( NSDictionary *comment in comments )
        {
            [newComments addObject:[DAComment commentWithData:comment]];
        }
        
        review.comments = [newComments copy];
    }
    
    return review;
}

@end
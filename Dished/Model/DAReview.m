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
    return [[DAReview alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        _name              = data[@"name"];
        _creator_id        = [data[@"creator_id"] integerValue];
        _creator_username  = data[@"creator_username"];
        _creator_img_thumb = data[@"creator_img_thumb"];
        _creator_type      = data[@"creator_type"];
        _grade             = data[@"grade"];
        _comment           = nilOrJSONObjectForKey( data, @"comment" );
        _price             = nilOrJSONObjectForKey( data, @"price" );
        _img               = nilOrJSONObjectForKey( data, @"img" );
        _loc_id            = [data[@"loc_id"] integerValue];
        _loc_name          = data[@"loc_name"];
        _dish_id           = [data[@"dish_id"] integerValue];
        
        NSArray *yums = nilOrJSONObjectForKey( data, @"yums" );
        if( yums )
        {
            NSMutableArray *newYums = [NSMutableArray array];
            
            for( NSDictionary *yum in yums )
            {
                [newYums addObject:[DAUsername usernameWithData:yum]];
            }
            
            _yums = [newYums copy];
        }
        
        NSArray *comments = nilOrJSONObjectForKey( data, @"comments" );
        if( comments )
        {
            NSMutableArray *newComments = [NSMutableArray array];
            
            for( NSDictionary *comment in comments )
            {
                [newComments addObject:[DAComment commentWithData:comment]];
            }
            
            _comments = [newComments copy];
        }
        
        NSArray *hashtags = nilOrJSONObjectForKey( data, @"hashtags" );
        if( hashtags )
        {
            NSMutableArray *newHashtags = [NSMutableArray array];
            
            for( NSString *hashtag in hashtags )
            {
                DAHashtag *newHashtag = [[DAHashtag alloc] init];
                newHashtag.name = hashtag;
                
                [newHashtags addObject:newHashtag];
            }
            
            _hashtags = [newHashtags copy];
        }
    }
    
    return self;
}

@end
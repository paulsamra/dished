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
        _img               = nilOrJSONObjectForKey( data, @"img" );
        _name              = nilOrJSONObjectForKey( data, @"name" );
        _grade             = nilOrJSONObjectForKey( data, @"grade" );
        _price             = nilOrJSONObjectForKey( data, @"price" );
        _comment           = nilOrJSONObjectForKey( data, @"comment" );
        _loc_name          = nilOrJSONObjectForKey( data, @"loc_name" );
        _creator_type      = nilOrJSONObjectForKey( data, @"creator_type" );
        _creator_username  = nilOrJSONObjectForKey( data, @"creator_username" );
        _creator_img_thumb = nilOrJSONObjectForKey( data, @"creator_img_thumb" );

        _caller_yumd       = [data[@"caller_yumd"]  boolValue];
        _creator_id        = [data[@"creator_id"]   integerValue];
        _loc_id            = [data[@"loc_id"]       integerValue];
        _dish_id           = [data[@"dish_id"]      integerValue];
        _num_comments      = [data[@"num_comments"] integerValue];
        
        NSTimeInterval timeInterval = [data[@"created"] doubleValue];
        _created = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
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
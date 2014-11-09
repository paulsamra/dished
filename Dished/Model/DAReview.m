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
        _img               = nilOrJSONObjectForKey( data, kImgKey );
        _name              = nilOrJSONObjectForKey( data, kNameKey );
        _grade             = nilOrJSONObjectForKey( data, kGradeKey );
        _price             = nilOrJSONObjectForKey( data, kPriceKey );
        _comment           = nilOrJSONObjectForKey( data, kCommentKey );
        _loc_name          = nilOrJSONObjectForKey( data, @"loc_name" );
        _img_thumb         = nilOrJSONObjectForKey( data, kImgThumbKey );
        _creator_type      = nilOrJSONObjectForKey( data, @"creator_type" );
        _creator_username  = nilOrJSONObjectForKey( data, @"creator_username" );
        _creator_img_thumb = nilOrJSONObjectForKey( data, @"creator_img_thumb" );

        _loc_id            = [nilOrJSONObjectForKey( data, kLocationIDKey )  integerValue];
        _dish_id           = [nilOrJSONObjectForKey( data, @"dish_id" )      integerValue];
        _num_yums          = [nilOrJSONObjectForKey( data, @"num_yums" )     integerValue];
        _review_id         = [nilOrJSONObjectForKey( data, kIDKey )          integerValue];
        _creator_id        = [nilOrJSONObjectForKey( data, @"creator_id" )   integerValue];
        _caller_yumd       = [nilOrJSONObjectForKey( data, @"caller_yumd" )     boolValue];
        _num_comments      = [nilOrJSONObjectForKey( data, @"num_comments" ) integerValue];
        
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
        
        NSDictionary *location = nilOrJSONObjectForKey( data, kLocationKey );
        if( location )
        {
            _loc_id    = [nilOrJSONObjectForKey( location, kIDKey ) integerValue];
            _loc_name  = nilOrJSONObjectForKey( location, kNameKey );
            _latitude  = [nilOrJSONObjectForKey( location, kLatitudeKey ) doubleValue];
            _longitude = [nilOrJSONObjectForKey( location, kLongitudeKey ) doubleValue];
        }
    }
    
    return self;
}

@end
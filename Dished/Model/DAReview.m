//
//  DAReview.m
//  Dished
//
//  Created by Ryan Khalili on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReview.h"
#import "DAUsername.h"


@interface DAReview()

@property (strong, nonatomic) NSArray *yumUsernameStrings;
@property (strong, nonatomic) NSArray *hashtagStrings;

@end


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
        _loc_name          = nilOrJSONObjectForKey( data, kLocationNameKey );
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
        
        NSTimeInterval timeInterval = [nilOrJSONObjectForKey( data, kCreatedKey ) doubleValue];
        _created = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        NSArray *yums = nilOrJSONObjectForKey( data, @"yums" );
        if( yums )
        {
            NSMutableArray *newYums = [NSMutableArray array];
            NSMutableArray *newYumsStrings = [NSMutableArray array];
            
            for( NSDictionary *yum in yums )
            {
                DAUsername *username = [DAUsername usernameWithData:yum];
                [newYums addObject:username];
                [newYumsStrings addObject:username.username];
            }
            
            _yums = newYums;
            _yumUsernameStrings = newYumsStrings;
        }
        
        NSArray *comments = nilOrJSONObjectForKey( data, @"comments" );
        if( comments )
        {
            NSMutableArray *newComments = [NSMutableArray array];
            
            for( NSDictionary *comment in comments )
            {
                [newComments addObject:[DAComment commentWithData:comment]];
            }
            
            _comments = newComments;
        }
        
        NSArray *hashtags = nilOrJSONObjectForKey( data, @"hashtags" );
        if( hashtags )
        {
            NSMutableArray *newHashtags = [NSMutableArray array];
            NSMutableArray *hashtagStrings = [NSMutableArray array];
            
            for( NSString *hashtag in hashtags )
            {
                DAHashtag *newHashtag = [[DAHashtag alloc] init];
                newHashtag.name = hashtag;
                
                [newHashtags addObject:newHashtag];
                [hashtagStrings addObject:hashtag];
            }
            
            _hashtags = newHashtags;
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

- (NSArray *)yumsStringArray
{
    return self.yumUsernameStrings;
}

- (NSArray *)hashtagsStringArray
{
    return self.hashtagStrings;
}

@end
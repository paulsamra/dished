//
//  DANewsItem.m
//  Dished
//
//  Created by Ryan Khalili on 9/17/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserNews.h"


@implementation DAUserNews

+ (DAUserNews *)userNewsWithData:(id)data
{
    return [[DAUserNews alloc] initWithData:data];
}

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        NSTimeInterval timeInterval = [data[@"created"] doubleValue];
        _created  = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        _type     = nilOrJSONObjectForKey( data, @"type" );
        _comment  = nilOrJSONObjectForKey( data, @"comment" );
        _username = nilOrJSONObjectForKey( data, @"username" );
        
        _viewed    = [data[@"viewed"]    boolValue];
        _item_id   = [data[@"id"]        integerValue];
        _review_id = [data[@"review_id"] integerValue];
    }
    
    return self;
}

- (NSString *)formattedString
{
    NSString *string = @"";
    
    if( [self.type isEqualToString:kUserNewsFollowNotification] )
    {
        string = [NSString stringWithFormat:@"%@ just started following you!", self.username];
    }
    else if( [self.type isEqualToString:kUserNewsReviewYumNotification] )
    {
        string = [NSString stringWithFormat:@"%@ YUMMED your review.", self.username];
    }
    else if( [self.type isEqualToString:kUserNewsReviewCommentNotification] )
    {
        string = [NSString stringWithFormat:@"%@ left a comment on your review: %@", self.username, self.comment];
    }
    else if( [self.type isEqualToString:kUserNewsReviewCommentMentionNotification] )
    {
        string = [NSString stringWithFormat:@"%@ mentioned you in a review: %@", self.username, self.comment];
    }
    
    return string;
}

@end
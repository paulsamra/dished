//
//  DAFeedComment+Utility.m
//  Dished
//
//  Created by Ryan Khalili on 9/16/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedComment+Utility.h"


@implementation DAFeedComment (Utility)

- (void)configureWithDictionary:(NSDictionary *)dictionary
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSTimeInterval timeInterval = [nilOrJSONObjectForKey( dictionary, kCreatedKey ) doubleValue];
    self.created = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    self.creator_type      = nilOrJSONObjectForKey( dictionary, @"creator_type" );
    self.creator_username  = nilOrJSONObjectForKey( dictionary, @"creator_username" );
    self.img_thumb         = nilOrJSONObjectForKey( dictionary, @"img_thumb" );
    self.comment           = nilOrJSONObjectForKey( dictionary, kCommentKey );
    
    self.creator_id        = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"creator_id" )];
    self.comment_id        = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, kIDKey )];
}

+ (NSString *)entityName
{
    return NSStringFromClass( [self class] );
}

@end
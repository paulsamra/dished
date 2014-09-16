//
//  DAFeedItem+Utility.m
//  Dished
//
//  Created by Ryan Khalili on 8/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedItem+Utility.h"


@implementation DAFeedItem(Utility)

- (void)configureWithDictionary:(NSDictionary *)dictionary
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSTimeInterval timeInterval = [nilOrJSONObjectForKey( dictionary, @"created" ) doubleValue];
    self.created = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    self.creator_img       = nilOrJSONObjectForKey( dictionary, @"creator_img" );
    self.creator_img_thumb = nilOrJSONObjectForKey( dictionary, @"creator_img_thumb" );
    self.creator_type      = nilOrJSONObjectForKey( dictionary, @"creator_type" );
    self.creator_username  = nilOrJSONObjectForKey( dictionary, @"creator_username" );
    self.grade             = nilOrJSONObjectForKey( dictionary, @"grade" );
    self.img               = nilOrJSONObjectForKey( dictionary, @"img" );
    self.img_thumb         = nilOrJSONObjectForKey( dictionary, @"img_thumb" );
    self.loc_name          = nilOrJSONObjectForKey( dictionary, @"loc_name" );
    self.name              = nilOrJSONObjectForKey( dictionary, @"name" );
    self.source            = nilOrJSONObjectForKey( dictionary, @"source" );
    self.caller_yumd       = nilOrJSONObjectForKey( dictionary, @"caller_yumd" );
    self.num_comments      = nilOrJSONObjectForKey( dictionary, @"num_comments" );
    self.img_public        = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"img_public" )];
    self.creator_id        = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"creator_id" )];
    self.item_id           = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"id" )];
    self.loc_id            = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"loc_id" )];    
}

+ (NSString *)entityName
{
    return NSStringFromClass( [self class] );
}

@end
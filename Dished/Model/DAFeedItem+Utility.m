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
    NSTimeInterval timeInterval = [nilOrJSONObjectForKey( dictionary, @"created" ) doubleValue];
    self.created = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    self.creator_id        = nilOrJSONObjectForKey( dictionary, @"creator_id"  );
    self.creator_img       = nilOrJSONObjectForKey( dictionary, @"creator_img" );
    self.creator_img_thumb = nilOrJSONObjectForKey( dictionary, @"creator_img_thumb" );
    self.creator_type      = nilOrJSONObjectForKey( dictionary, @"creator_type" );
    self.creator_username  = nilOrJSONObjectForKey( dictionary, @"creator_username" );
    self.grade             = nilOrJSONObjectForKey( dictionary, @"grade" );
    self.img               = nilOrJSONObjectForKey( dictionary, @"img" );
    self.img_thumb         = nilOrJSONObjectForKey( dictionary, @"img_thumb" );
    self.item_id           = nilOrJSONObjectForKey( dictionary, @"id" );
    self.loc_id            = nilOrJSONObjectForKey( dictionary, @"loc_id" );
    self.loc_name          = nilOrJSONObjectForKey( dictionary, @"loc_name" );
    self.name              = nilOrJSONObjectForKey( dictionary, @"name" );
    self.num_comments      = nilOrJSONObjectForKey( dictionary, @"num_comments" );
    self.source            = nilOrJSONObjectForKey( dictionary, @"source" );
    self.img_public        = nilOrJSONObjectForKey( dictionary, @"img_public" );
}

@end
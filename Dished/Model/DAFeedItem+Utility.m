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
    
    NSTimeInterval timeInterval = [nilOrJSONObjectForKey( dictionary, kCreatedKey ) doubleValue];
    self.created = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    self.creator_img       = nilOrJSONObjectForKey( dictionary, @"creator_img" );
    self.creator_img_thumb = nilOrJSONObjectForKey( dictionary, @"creator_img_thumb" );
    self.creator_type      = nilOrJSONObjectForKey( dictionary, @"creator_type" );
    self.creator_username  = nilOrJSONObjectForKey( dictionary, @"creator_username" );
    self.grade             = nilOrJSONObjectForKey( dictionary, kGradeKey );
    self.img               = nilOrJSONObjectForKey( dictionary, kImgKey );
    self.img_thumb         = nilOrJSONObjectForKey( dictionary, kImgThumbKey );
    self.loc_name          = nilOrJSONObjectForKey( dictionary, kLocationNameKey );
    self.name              = nilOrJSONObjectForKey( dictionary, kNameKey );
    self.source            = nilOrJSONObjectForKey( dictionary, @"source" );
    self.caller_yumd       = nilOrJSONObjectForKey( dictionary, @"caller_yumd" );
    self.num_comments      = nilOrJSONObjectForKey( dictionary, @"num_comments" );
    self.img_public        = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"img_public" )];
    self.creator_id        = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"creator_id" )];
    self.item_id           = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, kIDKey )];
    self.loc_id            = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, kLocationIDKey )];
    self.dish_id           = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, @"dish_id" )];
    
    id num_yums = nilOrJSONObjectForKey( dictionary, @"num_yums" );
    if( [num_yums isKindOfClass:[NSNumber class]] )
    {
        self.num_yums = num_yums;
    }
    else if( [num_yums isKindOfClass:[NSString class]] )
    {
        self.num_yums = [formatter numberFromString:num_yums];
    }
}

+ (NSString *)entityName
{
    return NSStringFromClass( self );
}

@end
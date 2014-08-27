//
//  DAFeedItem+Utility.h
//  Dished
//
//  Created by Ryan Khalili on 8/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedItem.h"


@interface DAFeedItem(Utility)

- (void)configureWithDictionary:(NSDictionary *)dictionary;
+ (NSString *)entityName;

@end
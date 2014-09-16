//
//  DAFeedComment+Utility.h
//  Dished
//
//  Created by Ryan Khalili on 9/16/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedComment.h"


@interface DAFeedComment(Utility)

- (void)configureWithDictionary:(NSDictionary *)dictionary;
+ (NSString *)entityName;

@end
//
//  DATagManager.h
//  Dished
//
//  Created by Ryan Khalili on 11/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DATagManager : NSObject

+ (void)addUsernameInBackground:(NSString *)username;
+ (void)addHashtagInBackground:(NSString *)hashtag;
+ (NSArray *)usernamesForQuery:(NSString *)query;
+ (NSArray *)hashtagsForQuery:(NSString *)query;

@end
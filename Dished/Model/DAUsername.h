//
//  DAUsername.h
//  Dished
//
//  Created by Ryan Khalili on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAUsername : NSObject

@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *img_thumb;

@property (nonatomic) BOOL      isFollowed;
@property (nonatomic) NSInteger user_id;

+ (DAUsername *)usernameWithData:(id)data;

@end
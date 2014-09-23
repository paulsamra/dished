//
//  DAFollowingNews.h
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANews.h"
#import "DAUsername.h"


@interface DAFollowingNews : DANews

@property (copy,   nonatomic) NSString   *username;
@property (strong, nonatomic) NSArray    *users;
@property (strong, nonatomic) DAUsername *followed;

@property (nonatomic) NSInteger yum_count;


+ (DAFollowingNews *)followingNewsWithData:(id)data;

@end
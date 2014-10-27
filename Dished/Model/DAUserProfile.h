//
//  DAUserProfile.h
//  Dished
//
//  Created by Ryan Khalili on 10/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DADish.h"


@interface DAUserProfile : NSObject

@property (copy,   nonatomic) NSString *desc;
@property (copy,   nonatomic) NSString *type;
@property (copy,   nonatomic) NSString *username;
@property (copy,   nonatomic) NSString *lastName;
@property (copy,   nonatomic) NSString *firstName;
@property (copy,   nonatomic) NSString *img_thumb;
@property (strong, nonatomic) NSArray  *foodReviews;
@property (strong, nonatomic) NSArray  *wineReviews;
@property (strong, nonatomic) NSArray  *cocktailReviews;

@property (nonatomic) BOOL      is_private;
@property (nonatomic) BOOL      is_profile_owner;
@property (nonatomic) BOOL      caller_follows;
@property (nonatomic) NSInteger user_id;
@property (nonatomic) NSInteger num_following;
@property (nonatomic) NSInteger num_followers;
@property (nonatomic) NSInteger num_reviews;


- (id)initWithData:(id)data;

@end
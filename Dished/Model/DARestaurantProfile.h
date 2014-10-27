//
//  DARestaurantProfile.h
//  Dished
//
//  Created by Ryan Khalili on 10/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DADish.h"


@interface DARestaurantProfile : NSObject

@property (copy,   nonatomic) NSString *name;
@property (copy,   nonatomic) NSString *phone;
@property (copy,   nonatomic) NSString *username;
@property (copy,   nonatomic) NSString *img_thumb;
@property (copy,   nonatomic) NSString *avg_grade;
@property (strong, nonatomic) NSArray  *foodDishes;
@property (strong, nonatomic) NSArray  *wineDishes;
@property (strong, nonatomic) NSArray  *cocktailDishes;

@property (nonatomic) BOOL      is_private;
@property (nonatomic) BOOL      is_profile_owner;
@property (nonatomic) BOOL      caller_follows;
@property (nonatomic) double    latitude;
@property (nonatomic) double    longitude;
@property (nonatomic) NSInteger user_id;
@property (nonatomic) NSInteger loc_id;


- (id)initWithData:(id)data;

@end
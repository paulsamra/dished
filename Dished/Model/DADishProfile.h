//
//  DADishProfile.h
//  Dished
//
//  Created by Ryan Khalili on 9/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAReview.h"


@interface DADishProfile : NSObject

@property (copy,   nonatomic) NSString *name;
@property (copy,   nonatomic) NSString *desc;
@property (copy,   nonatomic) NSString *price;
@property (copy,   nonatomic) NSString *loc_name;
@property (copy,   nonatomic) NSString *grade;
@property (strong, nonatomic) NSArray  *images;
@property (strong, nonatomic) NSArray  *reviews;

@property (nonatomic) BOOL      additional_info;
@property (nonatomic) NSInteger dish_id;
@property (nonatomic) NSInteger loc_id;
@property (nonatomic) NSInteger num_yums;
@property (nonatomic) NSInteger num_images;

+ (DADishProfile *)profileWithData:(id)data;

@end
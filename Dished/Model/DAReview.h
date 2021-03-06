//
//  DAReview.h
//  Dished
//
//  Created by Ryan Khalili on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAComment.h"
#import "DAHashtag.h"


@interface DAReview : NSObject

@property (copy,   nonatomic) NSDate   *created;
@property (copy,   nonatomic) NSString *name;
@property (copy,   nonatomic) NSString *creator_username;
@property (copy,   nonatomic) NSString *creator_img_thumb;
@property (copy,   nonatomic) NSString *creator_type;
@property (copy,   nonatomic) NSString *grade;
@property (copy,   nonatomic) NSString *comment;
@property (copy,   nonatomic) NSString *source;
@property (copy,   nonatomic) NSString *price;
@property (copy,   nonatomic) NSString *img;
@property (copy,   nonatomic) NSString *img_thumb;
@property (copy,   nonatomic) NSString *loc_name;
@property (strong, nonatomic) NSArray  *yums;
@property (strong, nonatomic) NSArray  *hashtags;
@property (strong, nonatomic) NSArray  *comments;

@property (nonatomic) BOOL      caller_yumd;
@property (nonatomic) double    longitude;
@property (nonatomic) double    latitude;
@property (nonatomic) NSInteger dish_id;
@property (nonatomic) NSInteger review_id;
@property (nonatomic) NSInteger creator_id;
@property (nonatomic) NSInteger loc_id;
@property (nonatomic) NSInteger num_yums;
@property (nonatomic) NSInteger num_comments;

+ (DAReview *)reviewWithData:(id)data;

- (id)initWithData:(id)data;
- (NSArray *)hashtagsStringArray;

@end
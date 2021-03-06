//
//  DAExploreDishSearchResult.h
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DADish : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *grade;
@property (copy, nonatomic) NSString *avg_grade;
@property (copy, nonatomic) NSString *locationName;
@property (copy, nonatomic) NSString *imageURL;

@property (nonatomic) double    longitude;
@property (nonatomic) double    latitude;
@property (nonatomic) NSInteger dishID;
@property (nonatomic) NSInteger locationID;
@property (nonatomic) NSInteger numComments;
@property (nonatomic) NSInteger totalReviews;
@property (nonatomic) NSInteger friendReviews;
@property (nonatomic) NSInteger influencerReviews;

+ (DADish *)dishWithData:(id)data;

@end
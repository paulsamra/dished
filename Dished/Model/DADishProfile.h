//
//  DADishProfile.h
//  Dished
//
//  Created by Ryan Khalili on 9/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAReview.h"

extern NSString *const kDAPGradeA;
extern NSString *const kDAPGradeB;
extern NSString *const kDAPGradeC;
extern NSString *const kDAPGradeDF;
extern NSString *const kDAPGradeAll;


@interface DADishProfile : NSObject

@property (copy,   nonatomic) NSString     *name;
@property (copy,   nonatomic) NSString     *desc;
@property (copy,   nonatomic) NSString     *price;
@property (copy,   nonatomic) NSString     *type;
@property (copy,   nonatomic) NSString     *loc_name;
@property (copy,   nonatomic) NSString     *grade;
@property (strong, nonatomic) NSArray      *images;
@property (strong, nonatomic) NSDictionary *reviews;
@property (strong, nonatomic) NSDictionary *num_grades;

@property (nonatomic) BOOL      additional_info;
@property (nonatomic) NSInteger dish_id;
@property (nonatomic) NSInteger loc_id;
@property (nonatomic) NSInteger num_yums;
@property (nonatomic) NSInteger num_images;

@property (nonatomic) NSInteger aGrades;
@property (nonatomic) NSInteger bGrades;
@property (nonatomic) NSInteger cGrades;
@property (nonatomic) NSInteger dfGrades;

+ (DADishProfile *)profileWithData:(id)data;

- (void)setReviewData:(NSArray *)data forGradeKey:(NSString *)key;
- (void)addReviewData:(NSArray *)data forGradeKey:(NSString *)key;

@end
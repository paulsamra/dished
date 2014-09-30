//
//  DAExploreDishSearchResult.h
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAExploreDishSearchResult : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *grade;
@property (copy, nonatomic) NSString *locationName;
@property (copy, nonatomic) NSString *imageURL;

@property (nonatomic) NSInteger dishID;
@property (nonatomic) NSInteger locationID;
@property (nonatomic) NSInteger totalReviews;
@property (nonatomic) NSInteger friendReviews;
@property (nonatomic) NSInteger influencerReviews;

+ (DAExploreDishSearchResult *)dishSearchResultWithData:(id)data;

@end
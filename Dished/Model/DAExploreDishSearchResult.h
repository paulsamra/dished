//
//  DAExploreDishSearchResult.h
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAExploreDishSearchResult : NSObject

@property (copy, nonatomic) NSString *dishID;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *grade;
@property (copy, nonatomic) NSString *locationName;
@property (copy, nonatomic) NSString *locationID;
@property (copy, nonatomic) NSString *imageURL;

@property (nonatomic) int totalReviews;
@property (nonatomic) int friendReviews;
@property (nonatomic) int influencerReviews;

@end
//
//  DAReview.h
//  Dished
//
//  Created by Ryan Khalili on 7/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DANewReview : NSObject

@property (copy, nonatomic) NSArray   *hashtags;
@property (copy, nonatomic) NSString  *type;
@property (copy, nonatomic) NSString  *title;
@property (copy, nonatomic) NSString  *comment;
@property (copy, nonatomic) NSString  *price;
@property (copy, nonatomic) NSString  *rating;
@property (copy, nonatomic) NSString  *locationName;
@property (copy, nonatomic) NSString  *locationStreetNum;
@property (copy, nonatomic) NSString  *locationStreetName;
@property (copy, nonatomic) NSString  *locationCity;
@property (copy, nonatomic) NSString  *locationState;
@property (copy, nonatomic) NSString  *locationZip;
@property (copy, nonatomic) NSString  *locationPhone;

@property (nonatomic) double    locationLongitude;
@property (nonatomic) double    locationLatitude;
@property (nonatomic) NSInteger dishID;
@property (nonatomic) NSInteger googleID;
@property (nonatomic) NSInteger locationID;

@end
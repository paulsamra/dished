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

@property (strong, nonatomic) UIImage  *image;
@property (strong, nonatomic) NSArray  *hashtags;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *grade;
@property (strong, nonatomic) NSString *reviewID;
@property (strong, nonatomic) NSString *location;

@end
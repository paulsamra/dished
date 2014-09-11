//
//  DAGlobalReview.h
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAReview.h"


@interface DAGlobalReview : DAReview

@property (copy,   nonatomic) NSString *source;
@property (strong, nonatomic) NSDate *created;

@property (nonatomic) NSInteger review_id;

- (id)initWithData:(id)data;

@end
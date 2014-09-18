//
//  DANewsItem.h
//  Dished
//
//  Created by Ryan Khalili on 9/17/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DANewsItem : NSObject

@property (copy, nonatomic) NSDate   *created;
@property (copy, nonatomic) NSString *type;

@property (nonatomic) NSInteger item_id;

+ (DANewsItem *)newsItemWithData:(id)data;

@end
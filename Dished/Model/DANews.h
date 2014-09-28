//
//  DANews.h
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DANews : NSObject

@property (copy, nonatomic) NSDate   *created;
@property (copy, nonatomic) NSString *img;

@property (nonatomic) BOOL viewed;
@property (nonatomic) NSInteger item_id;


- (id)initWithData:(id)data;
- (NSString *)formattedString;

@end
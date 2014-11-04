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
@property (copy, nonatomic) NSString *user_img_thumb;

@property (nonatomic) BOOL      viewed;
@property (nonatomic) NSInteger item_id;
@property (nonatomic) NSInteger review_id;


- (id)initWithData:(id)data;
- (NSString *)formattedString;

@end
//
//  DANewsItem.h
//  Dished
//
//  Created by Ryan Khalili on 9/17/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAUserNews : NSObject

@property (copy, nonatomic) NSDate   *created;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *user_img_thumb;

@property (nonatomic) BOOL      viewed;
@property (nonatomic) NSInteger item_id;
@property (nonatomic) NSInteger review_id;


+ (DAUserNews *)userNewsWithData:(id)data;

- (NSString *)formattedString;

@end
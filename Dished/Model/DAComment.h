//
//  DAComment.h
//  Dished
//
//  Created by Ryan Khalili on 8/28/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAComment : NSObject

@property (copy,   nonatomic) NSDate   *created;
@property (strong, nonatomic) UIImage  *creator_img;
@property (strong, nonatomic) NSArray  *usernameMentions;
@property (copy,   nonatomic) NSString *comment;
@property (copy,   nonatomic) NSString *creator_username;
@property (copy,   nonatomic) NSString *creator_type;
@property (copy,   nonatomic) NSString *img_thumb;

@property (nonatomic) NSInteger creator_id;
@property (nonatomic) NSInteger comment_id;

+ (DAComment *)commentWithData:(id)data;

- (NSAttributedString *)attributedCommentStringWithFont:(UIFont *)font;

@end
//
//  DAHashtag.h
//  Dished
//
//  Created by Ryan Khalili on 7/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAHashtag : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *hashtagID;

+ (DAHashtag *)hashtagWithData:(id)data;

@end
//
//  DAFeedItem.h
//  Dished
//
//  Created by Ryan Khalili on 8/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DAFeedItem : NSManagedObject

@property (nonatomic, retain) NSDate   * created;
@property (nonatomic, retain) NSNumber * creator_id;
@property (nonatomic, retain) NSString * creator_img;
@property (nonatomic, retain) NSString * creator_img_thumb;
@property (nonatomic, retain) NSString * creator_type;
@property (nonatomic, retain) NSString * creator_username;
@property (nonatomic, retain) NSString * grade;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSString * img_thumb;
@property (nonatomic, retain) NSNumber * item_id;
@property (nonatomic, retain) NSNumber * loc_id;
@property (nonatomic, retain) NSString * loc_name;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * num_comments;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSNumber * img_public;

@end

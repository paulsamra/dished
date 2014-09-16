//
//  DAFeedComment.h
//  Dished
//
//  Created by Ryan Khalili on 9/16/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DAFeedItem;

@interface DAFeedComment : NSManagedObject

@property (nonatomic, retain) NSNumber   * comment_id;
@property (nonatomic, retain) NSString   * comment;
@property (nonatomic, retain) NSDate     * created;
@property (nonatomic, retain) NSString   * status;
@property (nonatomic, retain) NSNumber   * creator_id;
@property (nonatomic, retain) NSString   * creator_username;
@property (nonatomic, retain) NSString   * img_thumb;
@property (nonatomic, retain) NSString   * creator_type;
@property (nonatomic, retain) DAFeedItem *feedItem;

@end
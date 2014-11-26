//
//  DAManagedComment.h
//  Dished
//
//  Created by Ryan Khalili on 11/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DAFeedItem, DAManagedUsername;

@interface DAManagedComment : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * comment_id;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * creator_id;
@property (nonatomic, retain) NSString * creator_type;
@property (nonatomic, retain) NSString * creator_username;
@property (nonatomic, retain) NSString * img_thumb;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) DAFeedItem *feedItem;
@property (nonatomic, retain) NSSet *usernames;
@end

@interface DAManagedComment (CoreDataGeneratedAccessors)

- (void)addUsernamesObject:(DAManagedUsername *)value;
- (void)removeUsernamesObject:(DAManagedUsername *)value;
- (void)addUsernames:(NSSet *)values;
- (void)removeUsernames:(NSSet *)values;

@end

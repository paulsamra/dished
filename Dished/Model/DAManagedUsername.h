//
//  DAManagedUsername.h
//  Dished
//
//  Created by Ryan Khalili on 11/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DAManagedComment;

@interface DAManagedUsername : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) DAManagedComment *comment;

@end

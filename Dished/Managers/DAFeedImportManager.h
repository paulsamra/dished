//
//  DAImportManager.h
//  Dished
//
//  Created by Ryan Khalili on 8/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DACoreDataManager.h"
#import "DAFeedItem+Utility.h"
#import "DAManagedComment+Utility.h"
#import "DAManagedUsername.h"
#import "DAManagedHashtag.h"


@interface DAFeedImportManager : NSObject

- (void)importFeedItemsWithLimit:(NSUInteger)limit offset:(NSUInteger)offset completion:( void(^)( BOOL success, BOOL hasMoreData ) )completion;
- (NSFetchedResultsController *)fetchFeedItemsWithLimit:(NSUInteger)limit;
- (void)fetchFeedItemsInBackgroundWithLimit:(NSUInteger)limit completion:( void(^)( NSArray *feedItems ) )completion;

@end
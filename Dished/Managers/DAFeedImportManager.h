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
#import "DAFeedComment+Utility.h"


@interface DAFeedImportManager : NSObject

- (void)importFeedItemsWithLimit:(NSUInteger)limit offset:(NSUInteger)offset completion:( void(^)( BOOL success, BOOL hasMoreData ) )completion;
- (NSFetchedResultsController *)fetchFeedItemsWithLimit:(NSUInteger)limit;

@end
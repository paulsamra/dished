//
//  DAImportManager.m
//  Dished
//
//  Created by Ryan Khalili on 8/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedImportManager.h"
#import "DAAPIManager.h"


@interface DAFeedImportManager()

@end


@implementation DAFeedImportManager

- (void)importFeedItemsWithLimit:(NSUInteger)limit offset:(NSUInteger)offset completion:(void (^)( BOOL success, BOOL hasMoreData ) )completion
{
    [[DAAPIManager sharedManager] getFeedActivityWithLongitude:0 latitude:0 radius:0 offset:offset limit:limit
    completion:^( id response, NSError *error )
    {
        if( error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType == eErrorTypeDataNonexists )
            {
                completion( YES, NO );
            }
            else
            {
                completion( NO, YES );
            }
        }
        else if( response )
        {
            NSArray *itemIDs = [self itemIDsForData:response[kDataKey]];
            NSArray *timestamps = [self timestampsForData:response[kDataKey]];
            NSArray *matchingItems = offset == 0 ? [self feedItemsUpToTimestamp:[[timestamps lastObject] doubleValue]] : [self feedItemsBetweenTimestamps:timestamps];
            
            NSUInteger entityIndex = 0;
            
            for( int i = 0; i < itemIDs.count; i++ )
            {
                NSUInteger newItemIndex = i;
                
                if( entityIndex < matchingItems.count)
                {
                    DAFeedItem *managedItem = matchingItems[entityIndex];
                    
                    if( [timestamps[newItemIndex] doubleValue] < [managedItem.created timeIntervalSince1970] )
                    {
                        [[DACoreDataManager sharedManager] deleteEntity:managedItem];
                        entityIndex++;
                        i--;
                    }
                    else if( ![itemIDs[i] isEqualToNumber:managedItem.item_id] )
                    {
                        DAFeedItem *newManagedItem = (DAFeedItem *)[[DACoreDataManager sharedManager] createEntityWithClassName:[DAFeedItem entityName]];
                        [newManagedItem configureWithDictionary:response[kDataKey][newItemIndex]];
                        [self updateFeedItem:newManagedItem withCommentsData:response[kDataKey][newItemIndex][@"comments"]];
                    }
                    else
                    {
                        managedItem = matchingItems[entityIndex];
                        [managedItem configureWithDictionary:response[kDataKey][newItemIndex]];
                        [self updateFeedItem:managedItem withCommentsData:response[kDataKey][newItemIndex][@"comments"]];

                        entityIndex++;
                    }
                }
                else
                {
                    DAFeedItem *newManagedItem = (DAFeedItem *)[[DACoreDataManager sharedManager] createEntityWithClassName:[DAFeedItem entityName]];
                    [newManagedItem configureWithDictionary:response[kDataKey][newItemIndex]];
                    [self updateFeedItem:newManagedItem withCommentsData:response[kDataKey][newItemIndex][@"comments"]];
                }
            }
            
            [[DACoreDataManager sharedManager] saveDataInManagedContextUsingBlock:^( BOOL saved, NSError *error )
            {
                if( !saved || error )
                {
                    completion( NO, YES );
                }
                else
                {
                    completion( YES, YES );
                }
            }];
        }
        else
        {
            completion( NO, YES );
        }
    }];
}

- (void)updateFeedItem:(DAFeedItem *)feedItem withCommentsData:(id)data
{
    NSArray *comments = (NSArray *)data;
    NSMutableSet *commentItems = [NSMutableSet set];
    
    NSSet *existingComments = feedItem.comments;
    
    for( DAFeedComment *comment in existingComments )
    {
        [[DACoreDataManager sharedManager] deleteEntity:comment];
    }
    
    for( NSDictionary *comment in comments )
    {
        DAFeedComment *feedComment = (DAFeedComment *)[[DACoreDataManager sharedManager] createEntityWithClassName:[DAFeedComment entityName]];
        [feedComment configureWithDictionary:comment];
        feedComment.feedItem = feedItem;
        
        [commentItems addObject:feedComment];
    }
    
    [feedItem setComments:commentItems];
}

- (NSArray *)feedItemsBetweenTimestamps:(NSArray *)timestamps
{
    NSTimeInterval first = [[timestamps lastObject]  doubleValue];
    NSTimeInterval last  = [[timestamps firstObject] doubleValue];
    
    NSDate *fromDate = [NSDate dateWithTimeIntervalSince1970:first];
    NSDate *toDate   = [NSDate dateWithTimeIntervalSince1970:last];
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kCreatedKey ascending:NO];
    NSArray *sortDescriptors = @[ dateSortDescriptor ];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( ( %K >= %@ ) && ( %K <= %@ ) )", kCreatedKey, fromDate, kCreatedKey, toDate];
    
    NSString *entityName = [DAFeedItem entityName];
    
    NSArray *matchingItems = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:sortDescriptors predicate:predicate];
    
    return matchingItems;
}

- (NSArray *)feedItemsUpToTimestamp:(NSTimeInterval)timestamp
{
    NSDate *toDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kCreatedKey ascending:NO];
    NSArray *sortDescriptors = @[ dateSortDescriptor ];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K >= %@", kCreatedKey, toDate];
    
    NSString *entityName = [DAFeedItem entityName];
    
    NSArray *matchingItems = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:sortDescriptors predicate:predicate];
    
    return matchingItems;
}

- (NSArray *)itemIDsForData:(id)data
{
    NSMutableArray *itemIDs = [NSMutableArray array];
    
    for( NSDictionary *item in data )
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *itemID = [formatter numberFromString:item[kIDKey]];
        
        [itemIDs addObject:itemID];
    }
    
    return itemIDs;
}

- (NSArray *)timestampsForData:(id)data
{
    NSMutableArray *timestamps = [NSMutableArray array];
    
    for( NSDictionary *item in data )
    {
        NSNumber *itemID = item[kCreatedKey];
        
        [timestamps addObject:itemID];
    }
    
    return timestamps;
}

- (NSFetchedResultsController *)fetchFeedItemsWithLimit:(NSUInteger)limit
{
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kCreatedKey ascending:NO];
    NSArray *sortDescriptors = @[ dateSortDescriptor ];
    NSFetchedResultsController *fetchedResultsController = [[DACoreDataManager sharedManager] fetchedResultsControllerWithEntityName:[DAFeedItem entityName] sortDescriptors:sortDescriptors predicate:nil sectionName:kCreatedKey fetchLimit:limit];
    
    return fetchedResultsController;
}

@end
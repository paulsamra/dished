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
            id errorResponse = error.userInfo[[DAAPIManager errorResponseKey]];
            
            if( [errorResponse isKindOfClass:[NSDictionary class]] )
            {
                if( [errorResponse[@"error"] isKindOfClass:[NSString class]] )
                {
                    if( [errorResponse[@"error"] isEqualToString:@"data_nonexists"] )
                    {
                        completion( YES, NO );
                    }
                    else
                    {
                        completion( NO, YES );
                    }
                }
                else
                {
                    completion( NO, YES );
                }
            }
            else
            {
                completion( NO, YES );
            }
        }
        else if( response )
        {
            NSArray *itemIDs = [self itemIDsForData:response[@"data"]];
            NSArray *matchingItems = [self feedItemsMatchingIDs:itemIDs];
            
            NSUInteger entityIndex = 0;
            
            for( NSNumber *itemID in itemIDs )
            {
                NSUInteger newItemIndex = [itemIDs indexOfObject:itemID];
                
                if( entityIndex < matchingItems.count)
                {
                    DAFeedItem *managedItem = matchingItems[entityIndex];
                    
                    if( ![itemID isEqualToNumber:managedItem.item_id] )
                    {
                        DAFeedItem *newManagedItem = (DAFeedItem *)[[DACoreDataManager sharedManager] createEntityWithClassName:[DAFeedItem entityName]];
                        [newManagedItem configureWithDictionary:response[@"data"][newItemIndex]];
                        [self updateFeedItem:newManagedItem withCommentsData:response[@"data"][newItemIndex][@"comments"]];
                    }
                    else
                    {
                        managedItem = matchingItems[entityIndex];
                        [managedItem configureWithDictionary:response[@"data"][newItemIndex]];
                        [self updateFeedItem:managedItem withCommentsData:response[@"data"][newItemIndex][@"comments"]];

                        entityIndex++;
                    }
                }
                else
                {
                    DAFeedItem *newManagedItem = (DAFeedItem *)[[DACoreDataManager sharedManager] createEntityWithClassName:[DAFeedItem entityName]];
                    [newManagedItem configureWithDictionary:response[@"data"][newItemIndex]];
                    [self updateFeedItem:newManagedItem withCommentsData:response[@"data"][newItemIndex][@"comments"]];
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

- (NSArray *)feedItemsMatchingIDs:(NSArray *)itemIDs
{
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = @[ dateSortDescriptor ];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(item_id IN %@)", itemIDs];
    
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
        NSNumber *itemID = [formatter numberFromString:item[@"id"]];
        
        [itemIDs addObject:itemID];
    }
    
    return itemIDs;
}

- (NSFetchedResultsController *)fetchFeedItemsWithLimit:(NSUInteger)limit
{
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = @[ dateSortDescriptor ];
    NSFetchedResultsController *fetchedResultsController = [[DACoreDataManager sharedManager] fetchedResultsControllerWithEntityName:[DAFeedItem entityName] sortDescriptors:sortDescriptors predicate:nil sectionName:@"created" fetchLimit:limit];
    
    return fetchedResultsController;
}

@end
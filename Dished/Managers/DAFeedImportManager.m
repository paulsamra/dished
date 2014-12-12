//
//  DAImportManager.m
//  Dished
//
//  Created by Ryan Khalili on 8/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedImportManager.h"


@interface DAFeedImportManager()

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@end


@implementation DAFeedImportManager

- (id)init
{
    if( self = [super init] )
    {
        self.managedObjectContext = [[DACoreDataManager sharedManager] backgroundManagedContext];
    }
    
    return self;
}

- (void)importFeedItemsWithLimit:(NSUInteger)limit offset:(NSUInteger)offset completion:(void (^)( BOOL success, BOOL hasMoreData ) )completion
{
    [self getFeedDataWithLimit:limit offset:offset success:^( id response )
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
    failure:^( NSError *error )
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
    }];
}

- (NSArray *)test:(NSTimeInterval)timestamp
{
    NSDate *toDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kCreatedKey ascending:NO];
    NSArray *sortDescriptors = @[ dateSortDescriptor ];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K >= %@", kCreatedKey, toDate];
    
    NSString *entityName = [DAFeedItem entityName];
    NSFetchRequest *fetchRequest = [[DACoreDataManager sharedManager] fetchRequestWithName:entityName sortDescriptors:sortDescriptors predicate:predicate fetchLimit:0];
    
    NSArray *matchingItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return matchingItems;
}

- (void)updateFeedItem:(DAFeedItem *)feedItem withCommentsData:(id)data
{
    NSArray *comments = (NSArray *)data;
    
    NSSet *existingComments = feedItem.comments;
    
    for( DAManagedComment *comment in existingComments )
    {
        [[DACoreDataManager sharedManager] deleteEntity:comment];
    }
    
    for( NSDictionary *comment in comments )
    {
        DAManagedComment *feedComment = (DAManagedComment *)[[DACoreDataManager sharedManager] createEntityWithClassName:[DAManagedComment entityName]];
        [feedComment configureWithDictionary:comment];
        feedComment.feedItem = feedItem;
        
        NSArray *usernameMentions = nilOrJSONObjectForKey( comment, @"usernames" );
        
        for( NSString *username in usernameMentions )
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %K", username, kUsernameKey];
            NSString *entityName = NSStringFromClass( [DAManagedUsername class] );
            
            NSArray *matches = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:nil predicate:predicate];
            
            if( matches.count == 1 )
            {
                [feedComment addUsernamesObject:matches[0]];
            }
            else
            {
                DAManagedUsername *managedUsername = (DAManagedUsername *)[[DACoreDataManager sharedManager] createEntityWithClassName:entityName];
                managedUsername.username = username;
                
                [feedComment addUsernamesObject:managedUsername];
            }
        }
        
        [feedItem addCommentsObject:feedComment];
    }
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

- (void)getFeedDataWithLimit:(NSInteger)limit offset:(NSInteger)offset success:( void(^)( id response ) )success failure:( void(^)( NSError *error ) )failure
{
    NSDictionary *parameters = @{ kRowLimitKey : @(limit), kRowOffsetKey : @(offset) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    [[DAAPIManager sharedManager] GETRequest:kFeedURL withParameters:parameters success:^( id response )
    {
        success( response );
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self getFeedDataWithLimit:limit offset:offset success:success failure:failure];
        }
        else
        {
            CLSLog(@"Error getting feed: %@", error);
            NSLog(@"Error getting feed: %@", error);
            failure( error );
        }
    }];
}

@end
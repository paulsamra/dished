//
//  DAImportManager.m
//  Dished
//
//  Created by Ryan Khalili on 8/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedImportManager.h"
#import "DALocationManager.h"


typedef void(^GetFeedDataBlock)();

@interface DAFeedImportManager()

@property (strong, nonatomic) DALocationManager *locationManager;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (copy, nonatomic) GetFeedDataBlock feedDataBlock;

@end


@implementation DAFeedImportManager

- (id)init
{
    if( self = [super init] )
    {
        _locationManager = [[DALocationManager alloc] init];
        [_locationManager startUpdatingLocation];
        _managedObjectContext = [[DACoreDataManager sharedManager] mainManagedContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated) name:kLocationUpdateNotificationKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDenied) name:kLocationServicesDeniedKey object:nil];
    }
    
    return self;
}

- (void)importFeedItemsWithLimit:(NSUInteger)limit offset:(NSUInteger)offset completion:(void (^)( BOOL success, BOOL hasMoreData ) )completion
{
    [self getFeedDataWithLimit:limit offset:offset success:^( id response )
    {
        [self.managedObjectContext performBlock:^
        {
            NSArray *data = nilOrJSONObjectForKey( response, kDataKey );
            BOOL hasMoreData = data.count >= limit;
            
            NSArray *itemIDs = [self itemIDsForData:data];
            NSArray *timestamps = [self timestampsForData:data];
            NSArray *matchingItems = offset == 0 ? [self feedItemsUpToTimestamp:[[timestamps lastObject] doubleValue]] : [self feedItemsBetweenTimestamps:timestamps];
            
            NSUInteger entityIndex = 0;
            
            for( int i = 0; i < itemIDs.count; i++ )
            {
                NSUInteger newItemIndex = i;
                
                NSArray *comments = nilOrJSONObjectForKey( data[newItemIndex], kCommentsKey );
                NSArray *hashtags = nilOrJSONObjectForKey( data[newItemIndex], kHashtagsKey );
                
                if( entityIndex < matchingItems.count)
                {
                    DAFeedItem *managedItem = matchingItems[entityIndex];
                    
                    if( [timestamps[newItemIndex] doubleValue] < [managedItem.created timeIntervalSince1970] )
                    {
                        [[DACoreDataManager sharedManager] deleteEntity:managedItem inManagedObjectContext:self.managedObjectContext];
                        entityIndex++;
                        i--;
                    }
                    else if( ![itemIDs[i] isEqualToNumber:managedItem.item_id] )
                    {
                        DAFeedItem *newManagedItem = (DAFeedItem *)[[DACoreDataManager sharedManager] createEntityWithName:[DAFeedItem entityName] inManagedObjectContext:self.managedObjectContext];
                        [newManagedItem configureWithDictionary:data[newItemIndex]];
                        [self updateFeedItem:newManagedItem withComments:comments];
                        [self updateFeedItem:newManagedItem withHashtags:hashtags];
                    }
                    else
                    {
                        managedItem = matchingItems[entityIndex];
                        [managedItem configureWithDictionary:data[newItemIndex]];
                        [self updateFeedItem:managedItem withComments:comments];
                        [self updateFeedItem:managedItem withHashtags:hashtags];
                        
                        entityIndex++;
                    }
                }
                else
                {
                    DAFeedItem *newManagedItem = (DAFeedItem *)[[DACoreDataManager sharedManager] createEntityWithName:[DAFeedItem entityName] inManagedObjectContext:self.managedObjectContext];
                    [newManagedItem configureWithDictionary:data[newItemIndex]];
                    [self updateFeedItem:newManagedItem withComments:comments];
                    [self updateFeedItem:newManagedItem withHashtags:hashtags];
                }
            }
            
            NSError *error = nil;
            [self.managedObjectContext save:&error];
            
            dispatch_async( dispatch_get_main_queue(), ^
            {
                error ? completion( NO, hasMoreData ) : completion( YES, hasMoreData );
            });
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

- (void)updateFeedItem:(DAFeedItem *)feedItem withComments:(NSArray *)comments
{
    for( DAManagedComment *comment in feedItem.comments )
    {
        [[DACoreDataManager sharedManager] deleteEntity:comment inManagedObjectContext:self.managedObjectContext];
    }
    
    NSMutableSet *itemComments = [NSMutableSet set];
    
    for( NSDictionary *comment in comments )
    {
        DAManagedComment *feedComment = (DAManagedComment *)[[DACoreDataManager sharedManager] createEntityWithName:[DAManagedComment entityName] inManagedObjectContext:self.managedObjectContext];
        [feedComment configureWithDictionary:comment];
        feedComment.feedItem = feedItem;
        
        NSArray *usernameMentions = nilOrJSONObjectForKey( comment, @"usernames" );
        NSMutableSet *commentUsernames = [NSMutableSet set];
        
        for( NSString *username in usernameMentions )
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", kUsernameKey, username];
            NSString *entityName = NSStringFromClass( [DAManagedUsername class] );
            
            NSArray *matches = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:nil predicate:predicate inManagedObjectContext:self.managedObjectContext];
            
            if( matches.count > 0 )
            {
                [commentUsernames addObject:matches[0]];
            }
            else
            {
                DAManagedUsername *managedUsername = (DAManagedUsername *)[[DACoreDataManager sharedManager] createEntityWithName:entityName inManagedObjectContext:self.managedObjectContext];
                managedUsername.username = username;
                
                [commentUsernames addObject:managedUsername];
            }
        }
        
        [feedComment setUsernames:commentUsernames];
        [itemComments addObject:feedComment];
    }
    
    [feedItem setComments:itemComments];
}

- (void)updateFeedItem:(DAFeedItem *)feedItem withHashtags:(NSArray *)hashtags
{
    NSMutableSet *itemHashtags = [NSMutableSet set];
    
    for( NSString *hashtag in hashtags )
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ == %K", hashtag, kNameKey];
        NSString *entityName = NSStringFromClass( [DAManagedHashtag class] );
        
        NSArray *matches = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:nil predicate:predicate inManagedObjectContext:self.managedObjectContext];
        
        if( matches.count > 0 )
        {
            [itemHashtags addObject:matches[0]];
        }
        else
        {
            DAManagedHashtag *managedHashtag = (DAManagedHashtag *)[[DACoreDataManager sharedManager] createEntityWithName:entityName inManagedObjectContext:self.managedObjectContext];
            managedHashtag.name = hashtag;
            
            [itemHashtags addObject:managedHashtag];
        }
    }
    
    [feedItem setHashtags:itemHashtags];
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
    
    NSArray *matchingItems = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:sortDescriptors predicate:predicate inManagedObjectContext:self.managedObjectContext];
    
    return matchingItems;
}

- (NSArray *)feedItemsUpToTimestamp:(NSTimeInterval)timestamp
{
    NSDate *toDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kCreatedKey ascending:NO];
    NSArray *sortDescriptors = @[ dateSortDescriptor ];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K >= %@", kCreatedKey, toDate];
    
    NSString *entityName = [DAFeedItem entityName];
    
    NSArray *matchingItems = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:sortDescriptors predicate:predicate inManagedObjectContext:self.managedObjectContext];
    
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
    
    NSFetchRequest *fetchRequest = [[DACoreDataManager sharedManager] fetchRequestWithName:[DAFeedItem entityName] sortDescriptors:sortDescriptors predicate:nil fetchLimit:limit];
    
    return [[DACoreDataManager sharedManager] fetchedResultsControllerWithFetchRequest:fetchRequest sectionNameKeyPath:kCreatedKey inManagedObjectContext:[[DACoreDataManager sharedManager] mainManagedContext]];
}

- (void)locationDenied
{
    if( self.feedDataBlock )
    {
        self.feedDataBlock();
        self.feedDataBlock = nil;
    }
}

- (void)locationUpdated
{
    if( self.feedDataBlock )
    {
        self.feedDataBlock();
        self.feedDataBlock = nil;
    }
}

- (void)getFeedDataWithLimit:(NSInteger)limit offset:(NSInteger)offset success:( void(^)( id response ) )success failure:( void(^)( NSError *error ) )failure
{
    GetFeedDataBlock block = ^
    {
        double longitude = self.locationManager.currentLocation.longitude;
        double latitude = self.locationManager.currentLocation.latitude;
        NSDictionary *parameters = @{ kRowLimitKey : @(limit), kRowOffsetKey : @(offset), kLongitudeKey : @(longitude), kLatitudeKey : @(latitude) };
        
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
    };
    
    if( ![self.locationManager locationServicesEnabled] )
    {
        block();
    }
    else
    {
        self.feedDataBlock = block;
    }
}

- (void)fetchFeedItemsInBackgroundWithLimit:(NSUInteger)limit completion:( void(^)( NSArray *feedItems ) )completion
{
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kCreatedKey ascending:NO];
    NSArray *sortDescriptors = @[ dateSortDescriptor ];
    
    NSFetchRequest *fetchRequest = [[DACoreDataManager sharedManager] fetchRequestWithName:[DAFeedItem entityName] sortDescriptors:sortDescriptors predicate:nil fetchLimit:limit];
    
    NSManagedObjectContext *backgroundContext = [[DACoreDataManager sharedManager] backgroundManagedContext];
    NSManagedObjectContext *mainContext = [[DACoreDataManager sharedManager] mainManagedContext];
    
    [backgroundContext performBlock:^
    {
        NSError *error;
        NSArray *objects = [backgroundContext executeFetchRequest:fetchRequest error:&error];
        
        if( error )
        {
            if( completion )
            {
                completion( nil );
            }
        }
        
        NSMutableArray *objectIDs = [NSMutableArray new];
        for( NSManagedObject *object in objects )
        {
            [objectIDs addObject:object.objectID];
        }
        
        [mainContext performBlock:^
        {
            NSMutableArray *feedItems = [NSMutableArray new];
            
            for( NSManagedObjectID *objectID in objectIDs )
            {
                NSManagedObject *object = [mainContext objectWithID:objectID];
                [feedItems addObject:object];
            }
            
            if( completion )
            {
                completion( feedItems );
            }
        }];
    }];
}

@end
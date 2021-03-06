//
//  DACoreDataManager.m
//  Dished
//
//  Created by Ryan Khalili on 8/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACoreDataManager.h"


@interface DACoreDataManager()

@property (strong, nonatomic) NSManagedObjectModel         *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext       *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext       *backgroundManagedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation DACoreDataManager

+ (DACoreDataManager *)sharedManager
{
    static DACoreDataManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DACoreDataManager alloc] init];
    });
    
    return manager;
}

#pragma mark - setup

- (id)init
{
    self = [super init];
    
    if( self )
    {
        [self setupManagedObjectContext];
    }
    
    return self;
}

- (void)setupManagedObjectContext
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectoryURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    
    NSURL *persistentURL = [documentDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", kProjectName]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Dished" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSDictionary *options = @{ NSPersistentStoreFileProtectionKey : NSFileProtectionComplete,
                               NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };
    
    NSError *error = nil;
    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                       configuration:nil
                                                                                                 URL:persistentURL
                                                                                             options:options
                                                                                               error:&error];
    
    if( !persistentStore )
    {
        NSLog(@"CORE DATA ERROR: %@", error.description);
    }
    else
    {
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [self.managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        
        self.backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.backgroundManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [self.backgroundManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
        object:self.backgroundManagedContext queue:[NSOperationQueue mainQueue] usingBlock:^( NSNotification *notification )
        {
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
        object:self.mainManagedContext queue:nil usingBlock:^( NSNotification *note )
        {
            [self.backgroundManagedContext performBlock:^
            {
                [self.backgroundManagedContext mergeChangesFromContextDidSaveNotification:note];
            }];
        }];
    }
}

- (NSManagedObjectContext *)mainManagedContext
{
    return self.managedObjectContext;
}

- (NSManagedObjectContext *)backgroundManagedContext
{
    return self.backgroundManagedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsControllerWithFetchRequest:(NSFetchRequest *)fetchRequest
                                                      sectionNameKeyPath:(NSString *)sectionName
                                                  inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionName cacheName:nil];
    
    NSError *error = nil;
    BOOL success = [fetchedResultsController performFetch:&error];
    
    return success ? fetchedResultsController : nil;
}

- (NSArray *)fetchEntitiesWithName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithName:name sortDescriptors:sortDescriptors predicate:predicate fetchLimit:0];
    
    NSError *error  = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    return error ? nil : results;
}

- (NSFetchRequest *)fetchRequestWithName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate fetchLimit:(NSUInteger)limit
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:name];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = limit;
    
    return fetchRequest;
}

- (NSManagedObject *)createEntityWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    if( !name || !context )
    {
        return nil;
    }
    
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
}

- (void)deleteEntity:(NSManagedObject *)entity inManagedObjectContext:(NSManagedObjectContext *)context
{
    if( !entity || !context )
    {
        return;
    }
    
    [context deleteObject:entity];
}

- (void)resetStore
{
    NSPersistentStore *store = [self.persistentStoreCoordinator.persistentStores objectAtIndex:0];
    NSError *error = nil;
    NSURL *storeURL = store.URL;
    [self.persistentStoreCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    if( !error )
    {
        [self setupManagedObjectContext];
    }
}

@end
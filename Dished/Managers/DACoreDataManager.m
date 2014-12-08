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
        NSLog(@"ERROR: %@", error.description);
    }
    else
    {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        self.backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.backgroundManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:self.backgroundManagedContext queue:nil
        usingBlock:^( NSNotification *notification )
        {
            [self performSelectorOnMainThread:@selector(backgroundContextDidSave:) withObject:notification waitUntilDone:NO];
        }];
    }
}

- (void)backgroundContextDidSave:(NSNotification *)notification
{
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

- (NSManagedObjectContext *)mainManagedContext
{
    return self.managedObjectContext;
}

- (NSManagedObjectContext *)backgroundManagedContext
{
    return self.backgroundManagedObjectContext;
}

- (void)saveDataInManagedContextUsingBlock:( void (^)( BOOL saved, NSError *error ) )savedBlock
{
    NSError *saveError = nil;
    BOOL saveSuccess = [self.managedObjectContext save:&saveError];
    
    if( savedBlock )
    {
        savedBlock( saveSuccess, saveError );
    }
}

- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate sectionName:(NSString *)sectionName
{
    return [self fetchedResultsControllerWithEntityName:name sortDescriptors:sortDescriptors predicate:predicate sectionName:sectionName fetchLimit:0];
}

- (NSArray *)fetchEntitiesWithName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithName:name sortDescriptors:sortDescriptors predicate:predicate fetchLimit:0];
    
    NSError *error  = nil;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return error ? nil : results;
}

- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate sectionName:(NSString *)sectionName fetchLimit:(NSUInteger)limit
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithName:name sortDescriptors:sortDescriptors predicate:predicate fetchLimit:limit];
    
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionName cacheName:nil];
    
    NSError *error = nil;
    BOOL success = [resultsController performFetch:&error];
    
    return success ? resultsController : nil;
}

- (NSFetchRequest *)fetchRequestWithName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate fetchLimit:(NSUInteger)limit
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:name];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = limit;
    
    return fetchRequest;
}

- (NSManagedObject *)createEntityWithClassName:(NSString *)className
{
    return [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:self.managedObjectContext];
}

- (void)deleteEntity:(NSManagedObject *)entity
{
    [self.managedObjectContext deleteObject:entity];
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
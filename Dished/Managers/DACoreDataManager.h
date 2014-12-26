//
//  DACoreDataManager.h
//  Dished
//
//  Created by Ryan Khalili on 8/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DACoreDataManager : NSObject

+ (DACoreDataManager *)sharedManager;

- (NSManagedObjectContext *)mainManagedContext;
- (NSManagedObjectContext *)backgroundManagedContext;

- (NSArray *)fetchEntitiesWithName:(NSString *)name
                   sortDescriptors:(NSArray *)sortDescriptors
                         predicate:(NSPredicate *)predicate
            inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)name
                                                       sortDescriptors:(NSArray *)sortDescriptors
                                                             predicate:(NSPredicate *)predicate
                                                           sectionName:(NSString *)sectionName;

- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)name
                                                       sortDescriptors:(NSArray *)sortDescriptors
                                                             predicate:(NSPredicate *)predicate
                                                           sectionName:(NSString *)sectionName
                                                            fetchLimit:(NSUInteger)limit;

- (NSFetchRequest *)fetchRequestWithName:(NSString *)name
                         sortDescriptors:(NSArray *)sortDescriptors
                               predicate:(NSPredicate *)predicate
                              fetchLimit:(NSUInteger)limit;


- (NSManagedObject *)createEntityWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)deleteEntity:(NSManagedObject *)entity inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)resetStore;

@end
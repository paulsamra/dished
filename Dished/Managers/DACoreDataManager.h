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

- (void)saveDataInManagedContextUsingBlock:( void (^)( BOOL saved, NSError *error ) )savedBlock;

- (NSArray *)fetchEntitiesWithName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate;
- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate sectionName:(NSString *)sectionName;
- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate sectionName:(NSString *)sectionName fetchLimit:(NSUInteger)limit;
- (NSFetchRequest *)fetchRequestWithName:(NSString *)name sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate fetchLimit:(NSUInteger)limit;


- (NSManagedObject *)createEntityWithClassName:(NSString *)className;
- (void)deleteEntity:(NSManagedObject *)entity;
- (void)resetStore;

@end
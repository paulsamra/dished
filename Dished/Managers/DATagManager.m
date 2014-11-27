//
//  DATagManager.m
//  Dished
//
//  Created by Ryan Khalili on 11/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DATagManager.h"
#import "DAManagedUsername.h"
#import "DAManagedHashtag.h"
#import "DACoreDataManager.h"


@interface DATagManager()

@end


@implementation DATagManager

+ (DATagManager *)sharedManager
{
    static DATagManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DATagManager alloc] init];
    });
    
    return manager;
}

- (NSArray *)usernamesForQuery:(NSString *)query
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@", kUsernameKey, query];
    NSString *name = NSStringFromClass( [DAManagedUsername class] );
    
    NSArray *matches = [[DACoreDataManager sharedManager] fetchEntitiesWithName:name sortDescriptors:nil predicate:predicate];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for( DAManagedUsername *managedUsername in matches )
    {
        [array addObject:managedUsername.username];
    }
    
    return array;
}

- (NSArray *)hashtagsForQuery:(NSString *)query
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@", kNameKey, query];
    NSString *name = NSStringFromClass( [DAManagedHashtag class] );
    
    NSArray *matches = [[DACoreDataManager sharedManager] fetchEntitiesWithName:name sortDescriptors:nil predicate:predicate];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for( DAManagedHashtag *managedHashtag in matches )
    {
        [array addObject:managedHashtag.name];
    }
    
    return array;
}

- (void)addUsernameInBackground:(NSString *)username
{
    [[[DACoreDataManager sharedManager] backgroundManagedContext] performBlock:^
    {
        NSString *className = NSStringFromClass( [DAManagedUsername class] );
        NSManagedObjectContext *backgroundManagedContext = [[DACoreDataManager sharedManager] backgroundManagedContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", kUsernameKey, username];
        NSFetchRequest *fetchRequest = [[DACoreDataManager sharedManager] fetchRequestWithName:className sortDescriptors:nil predicate:predicate fetchLimit:0];
        NSUInteger count = [backgroundManagedContext countForFetchRequest:fetchRequest error:nil];
        
        if( count == 0 )
        {
            DAManagedUsername *managedUsername = (DAManagedUsername *)[NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[DACoreDataManager sharedManager] backgroundManagedContext]];
            
            managedUsername.username = username;
            
            [[[DACoreDataManager sharedManager] backgroundManagedContext] save:nil];
        }
    }];
}

- (void)addHashtagInBackground:(NSString *)hashtag
{
    [[[DACoreDataManager sharedManager] backgroundManagedContext] performBlock:^
    {
        NSString *className = NSStringFromClass( [DAManagedHashtag class] );
        NSManagedObjectContext *backgroundManagedContext = [[DACoreDataManager sharedManager] backgroundManagedContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", kNameKey, hashtag];
        NSFetchRequest *fetchRequest = [[DACoreDataManager sharedManager] fetchRequestWithName:className sortDescriptors:nil predicate:predicate fetchLimit:0];
        NSUInteger count = [backgroundManagedContext countForFetchRequest:fetchRequest error:nil];
             
        if( count == 0 )
        {
            DAManagedHashtag *managedUsername = (DAManagedHashtag *)[NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[DACoreDataManager sharedManager] backgroundManagedContext]];
                 
            managedUsername.name = hashtag;
            
            [[[DACoreDataManager sharedManager] backgroundManagedContext] save:nil];
        }
    }];
}

@end
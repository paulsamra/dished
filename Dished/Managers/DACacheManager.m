//
//  DACacheManager.m
//  Dished
//
//  Created by Ryan Khalili on 12/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACacheManager.h"


@interface DACacheManager()

@property (strong, nonatomic) NSCache *cache;

@end


@implementation DACacheManager

+ (DACacheManager *)sharedManager
{
    static DACacheManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DACacheManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    if( self = [super init] )
    {
        _cache = [[NSCache alloc] init];
    }
    
    return self;
}

- (id)cachedValueForKey:(NSString *)key
{
    return [self.cache objectForKey:key];
}

- (void)setCachedValue:(id)value forKey:(NSString *)key
{
    [self.cache setObject:value forKey:key];
}

@end
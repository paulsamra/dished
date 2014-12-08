//
//  DACacheManager.h
//  Dished
//
//  Created by Ryan Khalili on 12/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DACacheManager : NSObject

+ (DACacheManager *)sharedManager;

- (id)cachedValueForKey:(NSString *)key;
- (void)setCachedValue:(id)value forKey:(NSString *)key;

@end
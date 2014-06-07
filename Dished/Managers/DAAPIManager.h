//
//  DAAPIManager.h
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface DAAPIManager : AFHTTPSessionManager

+ (DAAPIManager *)sharedManager;

- (void)checkAvailabilityOfUsername:(NSString *)username completion:(void(^)( BOOL available, NSError *error))completion;

@end
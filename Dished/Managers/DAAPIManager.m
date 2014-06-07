//
//  DAAPIManager.m
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAAPIManager.h"

static NSString *const baseAPIURL = @"http://54.215.184.64/api/";


@interface DAAPIManager()

@property (strong, nonatomic) NSURLSessionDataTask *usernameCheckTask;

@end


@implementation DAAPIManager

+ (DAAPIManager *)sharedManager
{
    static DAAPIManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DAAPIManager alloc] initWithBaseURL:[NSURL URLWithString:baseAPIURL]];
    });
    
    return manager;
}

- (void)checkAvailabilityOfUsername:(NSString *)username completion:(void(^)( BOOL available, NSError *error))completion
{
    if( self.usernameCheckTask )
    {
        [self.usernameCheckTask cancel];
    }
    
    NSDictionary *parameters = @{ @"username" : username };
    
    self.usernameCheckTask = [self GET:@"users/availability/username" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSLog(@"%@", responseObject);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        if( response.statusCode == 200 )
        {
            completion( YES, nil );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( error.code != -999 )
        {
            NSLog(@"%@", error);
            completion( NO, error );
        }
    }];
}

@end
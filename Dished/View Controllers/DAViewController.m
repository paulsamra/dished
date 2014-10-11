//
//  DAViewController.m
//  Dished
//
//  Created by Ryan Khalili on 9/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAViewController.h"
#import "DAAPIManager.h"


@interface DAViewController()

@property (strong, nonatomic) NSMutableArray *urlTasks;

@end


@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.urlTasks = [NSMutableArray array];
}

- (void)addURLTaskWithURL:(NSString *)url parameters:(NSDictionary *)parameters
             successBlock:( void (^)( NSURLSessionDataTask *task, id responseObject ) )successBlock
             failureBlock:( void (^)( NSURLSessionDataTask *task, NSError *error ) )failureBlock
{
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *authParameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
         
        NSURLSessionTask *urlTask = [[DAAPIManager sharedManager] GET:url parameters:authParameters success:successBlock failure:failureBlock];
         
        [self.urlTasks addObject:urlTask];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for( NSURLSessionTask *task in self.urlTasks )
    {
        [task cancel];
    }
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
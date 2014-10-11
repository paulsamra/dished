//
//  DAViewController.h
//  Dished
//
//  Created by Ryan Khalili on 9/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAViewController : UIViewController

- (void)addURLTaskWithURL:(NSString *)url parameters:(NSDictionary *)parameters
             successBlock:( void (^)( NSURLSessionDataTask *task, id responseObject ) )successBlock
             failureBlock:( void (^)( NSURLSessionDataTask *task, NSError *error ) )failureBlock;

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

@end
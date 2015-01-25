//
//  DADishedViewController.h
//  Dished
//
//  Created by Ryan Khalili on 1/7/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Error.h"


@interface DADishedViewController : UIViewController

- (void)loadData;
- (void)dataLoaded;
- (void)handleError:(NSError *)error;

@end
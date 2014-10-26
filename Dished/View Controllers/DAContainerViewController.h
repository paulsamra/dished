//
//  DAContainerViewController.h
//  Dished
//
//  Created by Ryan Khalili on 10/19/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAContainerViewController : UIViewController

- (void)moveToTabBar;
- (void)slideOutMenu;
- (void)moveToMenu;
- (BOOL)menuShowing;

@end


@interface UIViewController(DAContainerViewController)

- (DAContainerViewController *)containerViewController;

@end
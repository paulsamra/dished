//
//  DALocationTableViewController.h
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DALocationTableViewController : UITableViewController

@property (strong, nonatomic) id data;

- (void)setDetailItem:(id)newData;

@end

//
//  DARatingTableViewController.h
//  Dished
//
//  Created by Daryl Stimm on 7/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DANewReview.h"

@interface DARatingTableViewController : UITableViewController

@property (weak, nonatomic) DANewReview *review;

- (IBAction)done:(id)sender;

@end
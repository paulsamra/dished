//
//  DAReviewListViewController.h
//  Dished
//
//  Created by Ryan Khalili on 11/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAReview.h"


@interface DAReviewListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSArray *reviews;

@end
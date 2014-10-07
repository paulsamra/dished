//
//  DALocationTableViewController.h
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DANewReview.h"


@interface DAReviewLocationViewController : UITableViewController

@property (weak, nonatomic) DANewReview *review;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
//
//  DANegativeHashtagsViewController.h
//  Dished
//
//  Created by Ryan Khalili on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DANewReview.h"


@interface DANegativeHashtagsViewController : UITableViewController

@property (weak,   nonatomic) DANewReview *review;
@property (strong, nonatomic) NSMutableArray *selectedHashtags;

@end
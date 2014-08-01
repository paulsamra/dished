//
//  DAAddPlaceViewController.h
//  Dished
//
//  Created by Daryl Stimm on 7/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DANewReview.h"


@interface DAAddPlaceViewController : UITableViewController

@property (weak, nonatomic) DANewReview *review;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

- (IBAction)save:(id)sender;

@end
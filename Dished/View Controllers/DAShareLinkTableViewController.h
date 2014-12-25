//
//  DAShareLinkTableViewController.h
//  Dished
//
//  Created by Ryan Khalili on 12/18/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAShareLinkTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *linkCell;

@property (nonatomic) eSocialMediaType socialMediaType;

@end
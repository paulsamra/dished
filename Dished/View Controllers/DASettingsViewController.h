//
//  DASettingsViewController.h
//  Dished
//
//  Created by Ryan Khalili on 10/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DASettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *privacySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *dishPhotosSwitch;

@end
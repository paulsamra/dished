//
//  DANotificationSettingsViewController.h
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DANotificationSettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *offCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *followCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *everyoneCell;

@property (copy, nonatomic) NSString *notificationType;

@end
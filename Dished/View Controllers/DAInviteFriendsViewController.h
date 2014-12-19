//
//  DAInviteFriendsViewController.h
//  Dished
//
//  Created by Ryan Khalili on 12/18/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAInviteFriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel     *contactsPermissionLabel;
@property (weak, nonatomic) IBOutlet UILabel     *contactsFailureLabel;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet UITableView *facebookTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sourcePicker;

@end
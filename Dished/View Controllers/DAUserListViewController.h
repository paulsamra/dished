//
//  DAFollowListViewController.h
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    eUserListContentFollowing,
    eUserListContentFollowers,
    eUserListContentYums
} eUserListContent;


@interface DAUserListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) eUserListContent listContent;
@property (nonatomic) NSInteger object_id;

@end
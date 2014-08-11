//
//  DACurrentLocationViewController.h
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DACurrentLocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
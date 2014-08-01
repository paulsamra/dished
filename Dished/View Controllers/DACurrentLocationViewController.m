//
//  DACurrentLocationTableViewController.m
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACurrentLocationViewController.h"


@interface DACurrentLocationViewController()

@end


@implementation DACurrentLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)cancelChangeLocation:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if( tableView == self.searchDisplayController.searchResultsTableView )
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    cell.imageView.image = [UIImage imageNamed:@"3b-change-location_location-icon.png"];
    cell.textLabel.text = @"Current Location";
    
    return cell;
}

@end
//
//  DALocationTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALocationTableViewController.h"
#import "DAFormTableViewController.h"
#import "DAAddPlaceViewController.h"
#import "DAAPIManager.h"


@interface DALocationTableViewController() <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *locationNames;
@property (strong, nonatomic) NSArray *locationDistances;
@property (strong, nonatomic) NSDictionary *tableData;

@end


@implementation DALocationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1];
    
    self.locationNames = @[];
    self.locationDistances = @[];
    
    self.tableData = [[NSMutableDictionary alloc] initWithObjects:self.locationDistances forKeys:self.locationNames];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.tableData allKeys] count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if( indexPath.row == [[self.tableData allKeys] count] )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"newPlaceCell"];
    }
    else if( indexPath.row == ( [[self.tableData allKeys] count] + 1 ) )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"footerCell"];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
        
        cell.textLabel.text = [[self.tableData allKeys] objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.tableData objectForKey:[[self.tableData allKeys] objectAtIndex:indexPath.row]];
    }
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 0.5)];
    separatorLineView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:separatorLineView];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    double height = 0.0;
    
	if( indexPath.row == ( [[self.tableData allKeys] count] + 1 ) )
    {
        height = 300.0;
    }
    else
    {
        height = 44.0;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row < [[self.tableData allKeys] count] )
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        NSLog(@"%@", selectedCell.textLabel.text);
        
        NSArray *navigationStack = self.navigationController.viewControllers;
        DAFormTableViewController *parentController = [navigationStack objectAtIndex:([navigationStack count] -2)];
        [parentController setDetailItem:selectedCell.textLabel.text];
        
        [self.navigationController popViewControllerAnimated:YES];

    }
    else if( indexPath.row == [[self.tableData allKeys] count] )
    {
        [self performSegueWithIdentifier:@"add" sender:nil];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( searchText.length == 0 )
    {
        self.tableData = [NSDictionary dictionary];
        [self.tableView reloadData];
        return;
    }
    
    [[DAAPIManager sharedManager] searchLocationsWithQuery:searchText
    completion:^( NSArray *locations, NSArray *distances, NSError *error )
    {
        if( locations )
        {
            self.locationNames = locations;
            self.locationDistances = distances;
        }
        
        self.tableData = [NSDictionary dictionaryWithObjects:self.locationDistances forKeys:self.locationNames];
        
        [self.tableView reloadData];
    }];
}

- (void)setDetailItem:(id)newData
{
    if( _data != newData )
    {
        _data = newData;
    }
}

@end

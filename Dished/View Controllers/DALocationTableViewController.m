//
//  DALocationTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALocationTableViewController.h"
#import "DAFormTableViewController.h"
#import "DASaveLocationTableViewController.h"

@interface DALocationTableViewController () {
 
    NSMutableDictionary *tableDict;
}

@end

@implementation DALocationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *arrayOfPlaces = @[@"Taco Bell", @"Tako Bell", @"Mc Donalds"];
    
    NSArray *arrayOfDistances = @[@"40m", @"200m", @"15m"];
    
    tableDict = [[NSMutableDictionary alloc] initWithObjects:arrayOfDistances forKeys:arrayOfPlaces];

    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1];
}

- (BOOL)allowsFooterViewsToFloat
{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[tableDict allKeys] count] + 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    separatorLineView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:separatorLineView];
    
    if (indexPath.row == ([[tableDict allKeys] count])) {
        cell.textLabel.text = @"Add New Place";
        cell.detailTextLabel.text = @"";
        
        cell.imageView.image = [UIImage imageNamed:@"plus.png"];

    } else if (indexPath.row == ([[tableDict allKeys] count] + 1)) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 300.0)];
        view.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1];
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered.png"]];
        image.frame = CGRectMake((self.view.frame.size.width / 2) - ((482/2)/ 2), 5, 482/2, 43/2);
        [view addSubview:image];
		cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
		cell.backgroundView = view;
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        
    } else {
        cell.textLabel.text = [[tableDict allKeys] objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [tableDict objectForKey:[[tableDict allKeys] objectAtIndex:indexPath.row]];
        cell.imageView.image = [UIImage imageNamed:@"add_dish_location.png"	];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    double height = 0.0;
	if (indexPath.row == ([[tableDict allKeys] count] + 1)) {
        height = 300.0;
    } else {
        height = 44.0;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < ([[tableDict allKeys] count])) {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        NSLog(@"%@", selectedCell.textLabel.text);
        
        NSArray *navigationStack = self.navigationController.viewControllers;
        DAFormTableViewController *parentController = [navigationStack objectAtIndex:([navigationStack count] -2)];
        [parentController setDetailItem:selectedCell.textLabel.text];
        
        [self.navigationController popViewControllerAnimated:YES];

    } else if(indexPath.row == ([[tableDict allKeys] count])) {
		//Add new place selected.
        [self performSegueWithIdentifier:@"add" sender:nil];

    
    } else {
        //bottom cell
    }
        
}

- (void)setDetailItem:(id)newData {
    if (_data != newData) {
        _data = newData;
    }
    
}

@end

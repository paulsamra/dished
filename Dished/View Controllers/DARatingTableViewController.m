//
//  DARatingTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DARatingTableViewController.h"
#import "DARatingCustomTableViewCell.h"
#import "DAFormTableViewController.h"


@interface DARatingTableViewController ()
{
    NSMutableDictionary *gradeSelected;
    NSString *plusOrMinus;
    NSIndexPath *indexPathLastSelected;
}

@property (strong, nonatomic) NSArray *grades;

@end


@implementation DARatingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.grades = @[@"A", @"B", @"C", @"D", @"F"];
    
    gradeSelected = [[NSMutableDictionary alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DARatingCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
	cell.plusButton.hidden = YES;
    cell.minusButton.hidden = YES;
    
    cell.minusButton.titleLabel.textColor = [UIColor grayColor];
    cell.plusButton.titleLabel.textColor = [UIColor grayColor];
    
    [cell.plusButton addTarget:self action:@selector(plusOrMinusGrade:)  forControlEvents:UIControlEventTouchUpInside];
    [cell.minusButton addTarget:self action:@selector(plusOrMinusGrade:) forControlEvents:UIControlEventTouchUpInside];

    cell.gradeLabel.text = [self.grades objectAtIndex:indexPath.row];
    cell.gradeLabel.textColor = [UIColor grayColor];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.0;
}

- (void)plusOrMinusGrade:(id)sender
{
    DARatingCustomTableViewCell *cell = (DARatingCustomTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathLastSelected];

    if( [((UIButton *)sender).titleLabel.text isEqualToString:@"+"] )
    {
        cell.minusButton.titleLabel.textColor = [UIColor grayColor];
        cell.plusButton.titleLabel.textColor = [UIColor colorWithRed:0 green:0.55 blue:0.9 alpha:1];
    }
    else
    {
        cell.minusButton.titleLabel.textColor = [UIColor colorWithRed:0 green:0.55 blue:0.9 alpha:1];
        cell.plusButton.titleLabel.textColor = [UIColor grayColor];
    }
    
    [gradeSelected setObject:cell.gradeLabel.text forKey:@"grade"];
    [gradeSelected setObject:((UIButton *)sender).titleLabel.text forKey:@"plusorminus"];
    
    NSLog(@"dict: %@", gradeSelected);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DARatingCustomTableViewCell *cell = (DARatingCustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    indexPathLastSelected = indexPath;
    
    if( [cell.gradeLabel.textColor isEqual:[UIColor blueColor]] )
    {
        cell.gradeLabel.textColor = [UIColor grayColor];
        cell.plusButton.hidden = YES;
        cell.minusButton.hidden = YES;
    }
    else
    {
        cell.gradeLabel.textColor = [UIColor colorWithRed:0 green:0.55 blue:0.9 alpha:1];
        cell.plusButton.hidden = NO;
        cell.minusButton.hidden = NO;
    }
    
    [gradeSelected setObject:cell.gradeLabel.text forKey:@"grade"];
    [gradeSelected setObject:@"" forKey:@"plusorminus"];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DARatingCustomTableViewCell *cell = (DARatingCustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.gradeLabel.textColor = [UIColor grayColor];
    cell.plusButton.hidden = YES;
    cell.minusButton.hidden = YES;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake( 0, 0, self.tableView.frame.size.width, 50 );
    
    UIView *header = [[UIView alloc] initWithFrame:frame];
    header.backgroundColor = self.tableView.backgroundColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"Add Your Rating";
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    label.textColor = [UIColor grayColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    [header addSubview:label];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (IBAction)done:(id)sender
{
    NSArray *navigationStack = self.navigationController.viewControllers;

    DAFormTableViewController *parentController = [navigationStack objectAtIndex:( [navigationStack count] - 2 )];

    UILabel *label = [[UILabel alloc] init];
    
    label.text = [NSString stringWithFormat:@"%@ %@", [gradeSelected objectForKey:@"grade"], [gradeSelected objectForKey:@"plusorminus"]];
    
    [parentController setDetailItem:label];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

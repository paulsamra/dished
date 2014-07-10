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

@interface DARatingTableViewController () {
    NSArray *grades;
    NSMutableDictionary *gradeSelected;
    NSString *plusOrMinus;
    NSIndexPath *indexPathLastSelected;
}

@end

@implementation DARatingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    grades = @[@"A", @"B", @"C", @"D", @"F"];
    gradeSelected = [[NSMutableDictionary alloc] init];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DARatingCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.plusButton.hidden = YES;
    cell.minusButton.hidden = YES;
    cell.minusButton.titleLabel.textColor = [UIColor grayColor];
    cell.plusButton.titleLabel.textColor = [UIColor grayColor];
    [cell.plusButton addTarget:self action:@selector(plusOrMinusGrade:)
             forControlEvents:UIControlEventTouchUpInside];
    [cell.minusButton addTarget:self action:@selector(plusOrMinusGrade:)
               forControlEvents:UIControlEventTouchUpInside];

    cell.gradeLabel.text = [grades objectAtIndex:indexPath.row];
    cell.gradeLabel.textAlignment = NSTextAlignmentCenter;
    cell.gradeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:31.0];

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.0;
}
-(IBAction) plusOrMinusGrade:(id) sender {
    
    DARatingCustomTableViewCell *cell = (DARatingCustomTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathLastSelected];


    if ([((UIButton *)sender).titleLabel.text isEqualToString:@"+"]) {
        cell.minusButton.titleLabel.textColor = [UIColor grayColor];
        cell.plusButton.titleLabel.textColor = [UIColor blueColor];

    } else {
        cell.minusButton.titleLabel.textColor = [UIColor blueColor];
        cell.plusButton.titleLabel.textColor = [UIColor grayColor];

    }
    
    [gradeSelected setObject:cell.gradeLabel.text forKey:@"grade"];
    [gradeSelected setObject:((UIButton *)sender).titleLabel.text forKey:@"plusorminus"];
    
    NSLog(@"dict: %@", gradeSelected);

    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DARatingCustomTableViewCell *cell = (DARatingCustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    indexPathLastSelected = indexPath;
    
    if ([cell.gradeLabel.textColor isEqual:[UIColor blueColor]])
    {
        cell.gradeLabel.textColor = [UIColor grayColor];
        cell.plusButton.hidden = YES;
        cell.minusButton.hidden = YES;

    }
    else
    {
        cell.gradeLabel.textColor = [UIColor blueColor];
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
-(IBAction)done:(id)sender {
    NSArray *navigationStack = self.navigationController.viewControllers;

    DAFormTableViewController *parentController = [navigationStack objectAtIndex:([navigationStack count] -2)];

    UILabel *label = [[UILabel alloc] init];
    
    label.text = [NSString stringWithFormat:@"%@ %@", [gradeSelected objectForKey:@"grade"], [gradeSelected objectForKey:@"plusorminus"]];
    
    [parentController setDetailItem:label];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

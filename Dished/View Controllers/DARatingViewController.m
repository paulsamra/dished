//
//  DARatingTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DARatingViewController.h"
#import "DARatingCustomTableViewCell.h"
#import "DAReviewFormViewController.h"


@interface DARatingViewController ()

@property (strong, nonatomic) NSArray             *grades;
@property (strong, nonatomic) NSIndexPath         *indexPathLastSelected;
@property (strong, nonatomic) NSMutableDictionary *gradeSelected;

@end


@implementation DARatingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.grades = @[@"A", @"B", @"C", @"D", @"F"];
    self.gradeSelected = [[NSMutableDictionary alloc] init];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( self.review.rating.length > 0 )
    {
        const char *splitRating = [self.review.rating UTF8String];
        NSString *letterGrade = [NSString stringWithFormat:@"%c", splitRating[0]];
        NSString *plusOrMinus = @"";
        
        if( self.review.rating.length > 1 )
        {
            plusOrMinus = [NSString stringWithFormat:@"%c", splitRating[1]];
            [self.gradeSelected setObject:plusOrMinus forKey:@"plusorminus"];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self selectLetterGrade:letterGrade];
    }
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
    
    [cell.plusButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cell.minusButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    [cell.plusButton  addTarget:self action:@selector(plusOrMinusGrade:)  forControlEvents:UIControlEventTouchUpInside];
    [cell.minusButton addTarget:self action:@selector(plusOrMinusGrade:)  forControlEvents:UIControlEventTouchUpInside];

    cell.gradeLabel.text = [self.grades objectAtIndex:indexPath.row];
    cell.gradeLabel.textColor = [UIColor grayColor];
    
    if( [[self.gradeSelected objectForKey:@"grade"] isEqualToString:cell.gradeLabel.text] )
    {
        cell.gradeLabel.textColor = [UIColor dishedColor];
        cell.plusButton.hidden    = NO;
        cell.minusButton.hidden   = NO;
    }
    
    if( [[self.gradeSelected objectForKey:@"plusorminus"] isEqualToString:cell.plusButton.titleLabel.text] )
    {
        [cell.plusButton setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
    }
    
    if( [[self.gradeSelected objectForKey:@"plusorminus"] isEqualToString:cell.minusButton.titleLabel.text] )
    {
        [cell.minusButton setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.0;
}

- (void)plusOrMinusGrade:(id)sender
{
    DARatingCustomTableViewCell *cell = (DARatingCustomTableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathLastSelected];

	if( [((UIButton *)sender).currentTitleColor isEqual:[UIColor grayColor]] )
    {
        if( [((UIButton *)sender).titleLabel.text isEqualToString:@"+"] )
        {
            [cell.minusButton setTitleColor:[UIColor grayColor]   forState:UIControlStateNormal];
            [cell.plusButton  setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
        }
        else
        {
            [cell.minusButton setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
            [cell.plusButton  setTitleColor:[UIColor grayColor]   forState:UIControlStateNormal];
        }
        
        [self.gradeSelected setObject:((UIButton *)sender).titleLabel.text forKey:@"plusorminus"];
    }
    else
    {
        if( [((UIButton *)sender).titleLabel.text isEqualToString:@"+"] )
        {
            [cell.plusButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        else
        {
            [cell.minusButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        [self.gradeSelected setObject:@"" forKey:@"plusorminus"];
    }
    
    [self.gradeSelected setObject:cell.gradeLabel.text forKey:@"grade"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    DARatingCustomTableViewCell *cell = (DARatingCustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    self.indexPathLastSelected = indexPath;
    
    if( [cell.gradeLabel.textColor isEqual:[UIColor dishedColor]] )
    {
        cell.gradeLabel.textColor = [UIColor grayColor];
        cell.plusButton.hidden  = YES;
        cell.minusButton.hidden = YES;
    }
    else
    {
        cell.gradeLabel.textColor = [UIColor dishedColor];
        
        if( ![cell.gradeLabel.text isEqualToString:@"F"] )
        {
            cell.plusButton.hidden  = NO;
            cell.minusButton.hidden = NO;
        }
    }
    
    [self.gradeSelected setObject:cell.gradeLabel.text forKey:@"grade"];
    [self.gradeSelected setObject:@"" forKey:@"plusorminus"];
    
    [cell.plusButton  setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cell.minusButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DARatingCustomTableViewCell *cell = (DARatingCustomTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.gradeLabel.textColor = [UIColor grayColor];
    cell.plusButton.hidden  = YES;
    cell.minusButton.hidden = YES;
}

- (IBAction)done:(id)sender
{
    if( [self.gradeSelected objectForKey:@"grade"] )
    {
        NSString *grade = [NSString stringWithFormat:@"%@%@", [self.gradeSelected objectForKey:@"grade"], [self.gradeSelected objectForKey:@"plusorminus"]];
        self.review.rating = grade;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectLetterGrade:(NSString *)letterGrade
{
    int rowToSelect = 0;
    
    switch( [letterGrade characterAtIndex:0] )
    {
        case 'A': rowToSelect = 0; break;
        case 'B': rowToSelect = 1; break;
        case 'C': rowToSelect = 2; break;
        case 'D': rowToSelect = 3; break;
        case 'E': rowToSelect = 4; break;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowToSelect inSection:0];
    self.indexPathLastSelected = indexPath;
    [self.gradeSelected setObject:letterGrade forKey:@"grade"];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

@end
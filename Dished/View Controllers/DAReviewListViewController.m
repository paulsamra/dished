//
//  DAReviewListViewController.m
//  Dished
//
//  Created by Ryan Khalili on 11/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewListViewController.h"
#import "DADishTableViewCell.h"
#import "DAReviewDetailsViewController.h"

#define kDishCellID @"dishCell"


@interface DAReviewListViewController() <DADishTableViewCellDelegate>

@end


@implementation DAReviewListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DADishTableViewCell" bundle:nil];
    [self.tableView registerNib:searchCellNib forCellReuseIdentifier:kDishCellID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reviews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DADishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDishCellID];
    
    cell.isExplore = NO;
    
    DAReview *review = [self.reviews objectAtIndex:indexPath.row];
    
    cell.dishNameLabel.text = review.name;
    
    NSURL *url = [NSURL URLWithString:review.img_thumb];
    [cell.mainImageView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    cell.gradeLabel.text = review.grade;
    [cell.locationButton setTitle:review.loc_name forState:UIControlStateNormal];
    cell.rightNumberLabel.text = [NSString stringWithFormat:@"%d", (int)review.num_comments];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAReview *review = [self.reviews objectAtIndex:indexPath.row];
    
    [self pushReviewDetailsViewWithReviewID:review.review_id];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 97;
}

@end
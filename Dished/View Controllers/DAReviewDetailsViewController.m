//
//  DAReviewDetailsViewController.m
//  Dished
//
//  Created by POST on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewDetailsViewController.h"
#import "DAFeedCollectionViewCell.h"
@interface DAReviewDetailsViewController ()

@end

@implementation DAReviewDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAFeedCollectionViewCell *feedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
    
    NSString *usernameString = [NSString stringWithFormat:@"@%@", self.reviewDetailsDictionary[@"creator_username"]];
    
    [feedCell.creatorButton  setTitle:usernameString                         forState:UIControlStateNormal];
    [feedCell.titleButton    setTitle:self.reviewDetailsDictionary[@"name"]     forState:UIControlStateNormal];
    [feedCell.titleButton    setTag:indexPath.row];
    
    UIImage *locationIcon = [[UIImage imageNamed:@"feed_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [feedCell.locationButton setTitle:self.reviewDetailsDictionary[@"loc_name"] forState:UIControlStateNormal];
    [feedCell.locationButton setImage:locationIcon forState:UIControlStateNormal];
    [feedCell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
    
    //[feedCell.dishImageView setImageWithURL:self.reviewDetailsDictionary[@"img"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    feedCell.dishImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.reviewDetailsDictionary[@"img"]]]];
//    NSTimeInterval interval = [self.items[indexPath.row][@"created"] doubleValue];
//    [feedCell.timeLabel setAttributedTextForFeedItemDate:[NSDate dateWithTimeIntervalSince1970:interval]];
//    
    feedCell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    NSString *commentString = [NSString stringWithFormat:@"%d comments", [self.reviewDetailsDictionary[@"num_comments"] intValue]];
    [feedCell.commentsButton setTitle:commentString forState:UIControlStateNormal];
    
    return feedCell;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

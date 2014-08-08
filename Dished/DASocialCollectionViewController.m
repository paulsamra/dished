//
//  DASocialCollectionViewController.m
//  Dished
//
//  Created by POST on 8/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASocialCollectionViewController.h"
#import "DASocialCollectionViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DAAppDelegate.h"
#import "DATwitterManager.h"


@interface DASocialCollectionViewController ()

@property (strong, nonatomic) NSArray 		  *socialArray;
@property (strong, nonatomic) NSArray 		  *socialImageArray;
@property (strong, nonatomic) UIAlertView     *facebookLoginAlert;
@property (strong, nonatomic) UIAlertView     *twitterLoginAlert;

@end


@implementation DASocialCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.socialArray = [[NSArray alloc] initWithObjects:@"Facebook", @"Twitter", @"Email", @"Other", @"Done", nil];
    
    self.socialImageArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"add_dish_facebook.png"],
                             								 [UIImage imageNamed:@"add_dish_twitter.png"],
                                                             [UIImage imageNamed:@"add_dish_email.png"],
                                                             [UIImage imageNamed:@"add_dish_google_plus.png"],
                                                              nil];

    // Do any additional setup after loading the view.
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.socialArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView	
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DASocialCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.socialLabel.text = [self.socialArray objectAtIndex:indexPath.row];
    
    if( [cell.socialLabel.text isEqualToString:@"Done"] )
    {
        cell.frame = CGRectMake( cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, cell.frame.size.height);
        cell.socialImageView.hidden = YES;
        cell.socialLabel.hidden = YES;

        [cell.button setTitle:@"Done" forState:UIControlStateNormal];
    }
    else
    {
        cell.socialImageView.image = [self.socialImageArray objectAtIndex:indexPath.row];
        cell.socialImageView.alpha = 0.3;
        cell.socialLabel.alpha = 0.3;
        [cell.button setTitle:@"" forState:UIControlStateNormal];
    }

	return cell;
}

@end
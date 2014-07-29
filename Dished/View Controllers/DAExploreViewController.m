//
//  DAExploreViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreViewController.h"
#import "DAAPIManager.h"
#import "DANegativeHashtagsViewController.h"
#import "DAExploreCell.h"

@interface DAExploreViewController()
@property (weak, nonatomic) IBOutlet UICollectionView *exploreCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation DAExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    }

    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Editor's Picks";

    }
    else
    {
        cell.textLabel.text = @"Popular Now";
    }

    return cell;
}




- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAExploreCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];

    cell.image.image = [UIImage imageNamed:@"food.jpg"];

    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    return CGSizeMake((self.view.frame.size.width / 3)-4, (self.view.frame.size.width / 4)-4);
}


//- (UIEdgeInsets)collectionView:
//(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(20, 20, 50, 20);
//}
@end
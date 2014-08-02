//
//  DAExploreVC.m
//  Dished
//
//  Created by Ryan Khalili on 7/31/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreVC.h"
#import "DAAPIManager.h"
#import "UIImageView+WebCache.h"

static NSString *searchCellID = @"searchCell";


@interface DAExploreVC()

@property (strong, nonatomic) NSArray *imageURLs;
@property (strong, nonatomic) NSArray *hashtags;

@end


@implementation DAExploreVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DAExploreSearchTableViewCell" bundle:nil];
    [self.searchDisplayController.searchResultsTableView registerNib:searchCellNib forCellReuseIdentifier:searchCellID];
    
    [[DAAPIManager sharedManager] getExploreTabContentWithCompletion:
    ^( NSArray *hashtags, NSArray *imageURLs, NSError *error )
    {
        if( !error )
        {
            self.imageURLs = imageURLs;
            self.hashtags = hashtags;
            
            [self.collectionView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellID];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 97;
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
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    NSURL *url = [NSURL URLWithString:self.imageURLs[indexPath.row]];
    [imageView sd_setImageWithURL:url];
    
    return cell;
}

@end
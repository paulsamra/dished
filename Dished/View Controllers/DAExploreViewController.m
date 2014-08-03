//
//  DAExploreViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreViewController.h"
#import "DAExploreCollectionViewCell.h"
#import "DAAPIManager.h"
#import "UIImageView+WebCache.h"

static NSString *searchCellID = @"searchCell";


@interface DAExploreViewController()

@property (strong, nonatomic) NSArray *rowTitles;
@property (strong, nonatomic) NSArray *imageURLs;
@property (strong, nonatomic) NSArray *hashtags;

@end


@implementation DAExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
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
    if( tableView == self.searchDisplayController.searchResultsTableView )
    {
        return 100;
    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if( tableView == self.searchDisplayController.searchResultsTableView )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:searchCellID];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = self.rowTitles[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.searchDisplayController.searchResultsTableView )
    {
        return 97;
    }
    
    return tableView.rowHeight;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.hashtags count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAExploreCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString:self.imageURLs[indexPath.row]];
    [cell.imageView sd_setImageWithURL:url];
    
    DAHashtag *hashtag = [self.hashtags objectAtIndex:indexPath.row];
    cell.hashtagLabel.text = [NSString stringWithFormat:@"#%@", hashtag.name];
    
    return cell;
}

- (NSArray *)rowTitles
{
    if( !_rowTitles )
    {
        _rowTitles = @[ @"Editor's Picks", @"Popular Now" ];
    }
    
    return _rowTitles;
}

@end
//
//  DAFeedViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedViewController.h"
#import "DAFeedCollectionViewCell.h"
#import "DAFeedItem+Utility.h"
#import "DAAPIManager.h"
#import "DACoreDataManager.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface DAFeedViewController() <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSArray *items;

@property (nonatomic) NSInteger currentOffset;

@end


@implementation DAFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentOffset = 0;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_black_nav"]];
    
    self.collectionView.hidden = YES;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
//    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
//    NSArray *sortDescriptors = @[ dateSortDescriptor ];
//    
//    self.fetchedResultsController = [[DACoreDataManager sharedManager] fetchEntitiesWithClassName:NSStringFromClass([DAFeedItem class]) sortDescriptors:sortDescriptors sectionNameKeyPath:nil predicate:nil];
    
    [[DAAPIManager sharedManager] getFeedActivityWithLongitude:0 latitude:0 radius:0 offset:self.currentOffset limit:0
    completion:^( id response, NSError *error )
    {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        self.collectionView.hidden = NO;
        
        if( error || !response )
        {
            
        }
        else
        {
            self.items = response[@"data"];
            self.currentOffset += self.items.count;
            [self.collectionView reloadData];
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    id<NSFetchedResultsSectionInfo> resultsSection = self.fetchedResultsController.sections[section];
//    
//    return resultsSection.numberOfObjects;
    
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAFeedCollectionViewCell *feedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
    
    NSString *usernameString = [NSString stringWithFormat:@"@%@", self.items[indexPath.row][@"creator_username"]];
    
    [feedCell.creatorButton  setTitle:usernameString                         forState:UIControlStateNormal];
    [feedCell.titleButton    setTitle:self.items[indexPath.row][@"name"]     forState:UIControlStateNormal];
    [feedCell.locationButton setTitle:self.items[indexPath.row][@"loc_name"] forState:UIControlStateNormal];
    
    [feedCell.dishImageView setImageWithURL:self.items[indexPath.row][@"img"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    return feedCell;
}

@end
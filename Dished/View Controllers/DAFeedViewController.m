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
#import "UILabel+Dished.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface DAFeedViewController() <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSArray                    *items;
@property (strong, nonatomic) NSMutableArray             *changes;
@property (strong, nonatomic) UIRefreshControl           *refreshControl;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSCache					 *mainImageCache;

@property (nonatomic) NSInteger currentOffset;

@end


@implementation DAFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.mainImageCache)
    {
        self.mainImageCache = [[NSCache alloc] init];
        [self.mainImageCache setName:@"maincache"];
    }
    
    self.currentOffset = 0;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_black_nav"]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    self.collectionView.hidden = YES;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
//    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
//    NSArray *sortDescriptors = @[ dateSortDescriptor ];
//    
//    self.fetchedResultsController = [[DACoreDataManager sharedManager] fetchEntitiesWithClassName:NSStringFromClass([DAFeedItem class]) sortDescriptors:sortDescriptors sectionNameKeyPath:nil predicate:nil];
//    self.fetchedResultsController.delegate = self;
    
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

- (void)refreshFeed
{
    [[DAAPIManager sharedManager] getFeedActivityWithLongitude:0 latitude:0 radius:0 offset:self.currentOffset limit:0
    completion:^( id response, NSError *error )
    {
        [self.refreshControl endRefreshing];
        
        if( error || !response )
        {
             
        }
        else
        {
            
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
    
    UIImage *locationIcon = [[UIImage imageNamed:@"feed_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [feedCell.locationButton setTitle:self.items[indexPath.row][@"loc_name"] forState:UIControlStateNormal];
    [feedCell.locationButton setImage:locationIcon forState:UIControlStateNormal];
    [feedCell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
    
    
    UIImage *image = [self.mainImageCache objectForKey:self.items[indexPath.row][@"img"]];
    if (image)
    {
        feedCell.dishImageView.image = image;
        NSLog(@"pulled from cache");
    }
    else
    {
        [feedCell.dishImageView setImageWithURL:self.items[indexPath.row][@"img"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        NSString *urlstring = self.items[indexPath.row][@"img"];
        if (![urlstring isKindOfClass:[NSNull class]])
        {
            NSURL *url = [NSURL URLWithString:urlstring];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            [self.mainImageCache setObject:image forKey:self.items[indexPath.row][@"img"]];
            NSLog(@"pulled from feed");

        }


    }
    

    
    NSTimeInterval interval = [self.items[indexPath.row][@"created"] doubleValue];
    [feedCell.timeLabel setAttributedTextForFeedItemDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    
    feedCell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    NSString *commentString = [NSString stringWithFormat:@"%d comments", [self.items[indexPath.row][@"num_comments"] intValue]];
    [feedCell.commentsButton setTitle:commentString forState:UIControlStateNormal];
    
    return feedCell;
}

- (void)configureCell:(DAFeedCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DAFeedItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *usernameString = [NSString stringWithFormat:@"@%@", item.creator_username];
    
    [cell.creatorButton  setTitle:usernameString forState:UIControlStateNormal];
    [cell.titleButton    setTitle:item.name      forState:UIControlStateNormal];
    [cell.locationButton setTitle:item.loc_name  forState:UIControlStateNormal];
    
    NSURL *dishImageURL = [NSURL URLWithString:item.img];
    [cell.dishImageView setImageWithURL:dishImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    cell.gradeLabel.text = [item.grade uppercaseString];
    [cell.timeLabel setAttributedTextForFeedItemDate:item.created];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.changes = [NSMutableArray array];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    
    switch( type )
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [self.changes addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performBatchUpdates:^
    {
        for( NSDictionary *change in self.changes )
        {
            [change enumerateKeysAndObjectsUsingBlock:^( id key, id obj, BOOL *stop )
            {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                
                switch( type )
                {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                        
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                        
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                        
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    }
    completion:^( BOOL finished )
    {
        self.changes = nil;
    }];
}

@end
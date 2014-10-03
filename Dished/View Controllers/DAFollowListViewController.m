//
//  DAFollowListViewController.m
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFollowListViewController.h"
#import "DAAPIManager.h"
#import "DAUsername.h"
#import "UIImageView+WebCache.h"
#import "DAUserProfileViewController.h"


@interface DAFollowListViewController() <DAFollowListTableViewCellDelegate>

@property (strong, nonatomic) NSArray                 *usernameArray;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAFollowListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DAFollowListTableViewCell" bundle:nil];
    [self.tableView registerNib:searchCellNib forCellReuseIdentifier:@"followCell"];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.showFollowers ? [self loadFollowers] : [self loadFollowing];
    
    self.navigationItem.title = self.showFollowers ? @"Followers" : @"Following";
    
    self.tableView.rowHeight = 44.0;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)loadFollowers
{
    NSInteger userID = self.user_id;
    
    [[DAAPIManager sharedManager] getUserFollowersWithUserID:userID showRelations:YES completion:^( id response, NSError *error )
    {
        if( !response || error )
        {
            
        }
        else
        {
            self.usernameArray = [self usernamesWithData:response];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (void)loadFollowing
{
    NSInteger userID = self.user_id;
    
    [[DAAPIManager sharedManager] getUserFollowingWithUserID:userID showRelations:YES completion:^( id response, NSError *error )
    {
        if( !response || error )
        {
             
        }
        else
        {
            self.usernameArray = [self usernamesWithData:response];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (NSArray *)usernamesWithData:(id)data
{
    NSArray *dataArray = nilOrJSONObjectForKey( data, @"data" );
    NSMutableArray *usernames = [NSMutableArray array];
    
    for( NSDictionary *username in dataArray )
    {
        [usernames addObject:[DAUsername usernameWithData:username]];
    }
    
    return usernames;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.usernameArray.count == 0 ? 1 : self.usernameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAFollowListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followCell"];
    
    if( self.usernameArray.count == 0 )
    {
        cell.usernameLabel.text = @"Loading...";
        
        cell.accessoryView = self.spinner;
        cell.userInteractionEnabled = NO;
        [self.spinner startAnimating];
    }
    else
    {
        DAUsername *username = [self.usernameArray objectAtIndex:indexPath.row];
        
        cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", username.username];
        
        [self configureFollowButton:cell.followButton withFollowStatus:username.isFollowed];
        
        NSURL *imageURL = [NSURL URLWithString:username.img_thumb];
        [cell.userImageView sd_setImageWithURL:imageURL];
        
        cell.delegate = self;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAUsername *username = [self.usernameArray objectAtIndex:indexPath.row];
    
    DAUserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    userProfileViewController.username = username.username;
    userProfileViewController.user_id  = username.user_id;
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)configureFollowButton:(UIButton *)followButton withFollowStatus:(BOOL)isFollowed
{
    NSString *followButtonText = isFollowed ? @"Unfollow" : @"Follow";
    UIColor  *followButtonColor = isFollowed ? [UIColor redColor] : [UIColor followButtonColor];
    
    [followButton setTitle:followButtonText forState:UIControlStateNormal];
    [followButton setTitleColor:followButtonColor forState:UIControlStateNormal];
}

- (void)followButtonTappedOnFollowListTableViewCell:(DAFollowListTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DAUsername *username = [self.usernameArray objectAtIndex:indexPath.row];
    
    username.isFollowed ? [self unfollowUserID:username.user_id] : [self followUserID:username.user_id];
    [self configureFollowButton:cell.followButton withFollowStatus:!username.isFollowed];
    username.isFollowed = !username.isFollowed;
}

- (void)followUserID:(NSInteger)userID
{
    [[DAAPIManager sharedManager] followUserWithUserID:userID completion:nil];
}

- (void)unfollowUserID:(NSInteger)userID
{
    [[DAAPIManager sharedManager] unfollowUserWithUserID:userID completion:nil];
}

@end
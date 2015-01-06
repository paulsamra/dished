//
//  DAFollowListViewController.m
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserListViewController.h"
#import "DAUsername.h"
#import "UIImageView+WebCache.h"
#import "DAUserProfileViewController.h"
#import "DAUserManager.h"

static NSString *const kFollowCellIdentifier = @"followCell";


@interface DAUserListViewController() <DAUserListTableViewCellDelegate>

@property (strong, nonatomic) NSArray                 *usernameArray;
@property (strong, nonatomic) NSURLSessionTask        *loadTask;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAUserListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DAUserListTableViewCell" bundle:nil];
    [self.tableView registerNib:searchCellNib forCellReuseIdentifier:kFollowCellIdentifier];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    switch( self.listContent )
    {
        case eUserListContentFollowers:
            [self loadFollowers];
            self.navigationItem.title = @"Followers";
            break;
            
        case eUserListContentFollowing:
            [self loadFollowing];
            self.navigationItem.title = @"Following";
            break;
            
        case eUserListContentYums:
            [self loadYums];
            self.navigationItem.title = @"YUMs";
            break;
    }
    
    self.tableView.rowHeight = 44.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)loadFollowers
{
    __weak typeof( self ) weakSelf = self;
    
    NSDictionary *parameters = @{ kIDKey : @(weakSelf.object_id), kRelationKey : @(YES) };
    
    weakSelf.loadTask = [[DAAPIManager sharedManager] POSTRequest:kUserFollowersURL withParameters:parameters
    success:^( id response )
    {
        weakSelf.usernameArray = [weakSelf usernamesWithData:response];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadFollowers];
        }
    }];
}

- (void)loadFollowing
{
    __weak typeof( self ) weakSelf = self;
    
    NSDictionary *parameters = @{ kIDKey : @(weakSelf.object_id), kRelationKey : @(YES) };
    
    weakSelf.loadTask = [[DAAPIManager sharedManager] POSTRequest:kUserFollowingURL withParameters:parameters
    success:^( id response )
    {
        weakSelf.usernameArray = [weakSelf usernamesWithData:response];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadFollowing];
        }
    }];
}

- (void)loadYums
{
    __weak typeof( self ) weakSelf = self;
    
    NSDictionary *parameters = @{ kIDKey : @(weakSelf.object_id) };
    
    [[DAAPIManager sharedManager] GETRequest:kReviewYumsURL withParameters:parameters
    success:^( id response )
    {
        weakSelf.usernameArray = [weakSelf usernamesWithData:response];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadYums];
        }
    }];
}

- (void)dealloc
{
    [self.loadTask cancel];
}

- (NSArray *)usernamesWithData:(id)data
{
    NSArray *dataArray = nilOrJSONObjectForKey( data, kDataKey );
    
    if( self.listContent == eUserListContentYums )
    {
        dataArray = nilOrJSONObjectForKey( (NSDictionary *)dataArray, @"yums" );
    }
    
    NSMutableArray *usernames = [NSMutableArray array];
    
    for( NSDictionary *username in dataArray )
    {
        DAUsername *newUsername = [DAUsername usernameWithData:username];
        
        if( self.listContent == eUserListContentFollowing && self.object_id == [DAUserManager sharedManager].user_id )
        {
            newUsername.isFollowed = YES;
        }
        
        [usernames addObject:newUsername];
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
    DAUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFollowCellIdentifier];
    
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
        cell.userInteractionEnabled = YES;
        cell.accessoryView = nil;
        
        if( [username.username isEqualToString:[DAUserManager sharedManager].username] || self.listContent == eUserListContentYums )
        {
            cell.sideButton.hidden = YES;
        }
        else
        {
            cell.sideButton.hidden = NO;
            [self configureFollowButton:cell.sideButton withFollowStatus:username.isFollowed];
        }
        
        NSURL *imageURL = [NSURL URLWithString:username.img_thumb];
        [cell.userImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
        
        cell.delegate = self;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAUsername *username = [self.usernameArray objectAtIndex:indexPath.row];
    
    if( [username.type isEqualToString:kRestaurantUserType] )
    {
        [self pushrestaurantProfileWithUserID:username.user_id username:username.username];
    }
    else
    {
        [self pushUserProfileWithUsername:username.username];
    }
}

- (void)configureFollowButton:(UIButton *)followButton withFollowStatus:(BOOL)isFollowed
{
    NSString *followButtonText = isFollowed ? @"Unfollow" : @"Follow";
    UIColor  *followButtonColor = isFollowed ? [UIColor redColor] : [UIColor followButtonColor];
    
    [followButton setTitle:followButtonText forState:UIControlStateNormal];
    [followButton setTitleColor:followButtonColor forState:UIControlStateNormal];
}

- (void)sideButtonTappedOnFollowListTableViewCell:(DAUserListTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DAUsername *username = [self.usernameArray objectAtIndex:indexPath.row];
    
    username.isFollowed ? [self unfollowUserID:username.user_id] : [self followUserID:username.user_id];
    [self configureFollowButton:cell.sideButton withFollowStatus:!username.isFollowed];
    username.isFollowed = !username.isFollowed;
}

- (void)followUserID:(NSInteger)userID
{
    __weak typeof( self ) weakSelf = self;
    
    NSDictionary *parameters = @{ kIDKey : @(userID) };
    
    [[DAAPIManager sharedManager] POSTRequest:kFollowUserURL withParameters:parameters
    success:^( id response )
    {
        NSString *idName = [NSString stringWithFormat:@"%d", (int)weakSelf.object_id];
        [[NSNotificationCenter defaultCenter] postNotificationName:idName object:nil];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf followUserID:userID];
        }
    }];
}

- (void)unfollowUserID:(NSInteger)userID
{
    __weak typeof( self ) weakSelf = self;
    
    NSDictionary *parameters = @{ kIDKey : @(userID) };
    
    [[DAAPIManager sharedManager] POSTRequest:kUnfollowUserURL withParameters:parameters
    success:^( id response )
    {
        NSString *idName = [NSString stringWithFormat:@"%d", (int)weakSelf.object_id];
        [[NSNotificationCenter defaultCenter] postNotificationName:idName object:nil];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf unfollowUserID:userID];
        }
    }];
}

@end
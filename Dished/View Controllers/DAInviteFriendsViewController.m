//
//  DAInviteFriendsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 12/18/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAInviteFriendsViewController.h"
#import <AddressBook/AddressBook.h>
#import "DAUserManager.h"
#import "DAAppDelegate.h"

#define kCellIdentifier @"userCell"


@interface DAInviteFriendsViewController() <DAUserListTableViewCellDelegate>

@property (strong, nonatomic) UITableView             *selectedTableView;
@property (strong, nonatomic) NSMutableArray          *registrationData;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL isLoadingContacts;
@property (nonatomic) BOOL isLoadingFacebook;
@property (nonatomic) BOOL isFacebookUser;
@property (nonatomic) BOOL contactsFailure;
@property (nonatomic) BOOL contactsNotPermitted;

@end


@implementation DAInviteFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contactsNotPermitted = NO;
    self.contactsFailure = NO;
    self.sourcePicker.tintColor = [UIColor dishedColor];
    
    self.selectedTableView = self.contactsTableView;
    self.facebookTableView.hidden = YES;
    
    self.contactsTableView.tableFooterView = [UIView new];
    self.facebookTableView.tableFooterView = [UIView new];
    
    self.contactsPermissionLabel.hidden = YES;
    self.contactsFailureLabel.hidden = YES;
    self.facebookConnectLabel.hidden = YES;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    self.contactsTableView.rowHeight = 44.0;
    self.contactsTableView.estimatedRowHeight = 44.0;
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DAUserListTableViewCell" bundle:nil];
    [self.contactsTableView registerNib:searchCellNib forCellReuseIdentifier:kCellIdentifier];
    
    [self loadFacebookFriends];
    
    self.isLoadingContacts = YES;
    [DAAppDelegate getContactsAddressBookWithCompletion:^( BOOL granted, ABAddressBookRef addressBook, NSError *error )
    {
        if( error )
        {
            self.contactsFailure = YES;
            [self.spinner stopAnimating];
        }
        else if( !granted )
        {
            self.contactsNotPermitted = YES;
            [self.spinner stopAnimating];
        }
        else
        {
            [self getRegistrationStatusForContacts:[DAAppDelegate contactsWithAddressBook:addressBook]];
        }
        
        self.isLoadingContacts = NO;
    }];
}

- (void)loadFacebookFriends
{
    self.isLoadingFacebook = YES;
    
    if( FBSession.activeSession.state != FBSessionStateOpen || ![[DAUserManager sharedManager] isFacebookUser] )
    {
        self.isFacebookUser = NO;
        
        if( self.selectedTableView == self.facebookTableView )
        {
            self.facebookConnectLabel.hidden = NO;
            [self.spinner stopAnimating];
        }
        
        self.isLoadingFacebook = NO;
        return;
    }
    else
    {
        self.isFacebookUser = YES;
    }
}

- (NSString *)jsonEncodedStringWithArray:(NSArray *)array
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

- (void)getRegistrationStatusForContacts:(NSArray *)contacts
{
    NSDictionary *parameters = @{ kContactsKey : [self jsonEncodedStringWithArray:contacts] };
    
    [[DAAPIManager sharedManager] POSTRequest:kUserContactsRegisteredURL withParameters:parameters
    success:^( id response )
    {
        NSArray *data = nilOrJSONObjectForKey( response, kDataKey );
        NSMutableArray *contacts = [NSMutableArray array];
        
        for( NSDictionary *contact in data )
        {
            if( ![contact[@"registered"] boolValue] )
            {
                [contacts addObject:contact];
            }
        }
        
        self.registrationData = contacts;
        [self.contactsTableView reloadData];
        [self.spinner stopAnimating];
        self.isLoadingContacts = NO;
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self getRegistrationStatusForContacts:contacts];
        }
        else
        {
            self.contactsFailure = YES;
            [self.contactsTableView reloadData];
            [self.spinner stopAnimating];
            
            self.isLoadingContacts = NO;
        }
    }];
}

- (NSDictionary *)dictionaryWithName:(NSString *)name number:(NSString *)number email:(NSString *)email
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if( name )
    {
        dict[kNameKey] = name;
    }
    
    if( number )
    {
        dict[kPhoneKey] = number;
    }
    
    if( email )
    {
        dict[kEmailKey] = email;
    }
    
    return dict;
}

- (void)setContactsNotPermitted:(BOOL)contactsNotPermitted
{
    _contactsNotPermitted = contactsNotPermitted;
    self.contactsPermissionLabel.hidden = !contactsNotPermitted;
}

- (void)setContactsFailure:(BOOL)contactsFailure
{
    _contactsFailure = contactsFailure;
    self.contactsFailureLabel.hidden = !contactsFailure;
}

- (void)makeTableViewActive:(UITableView *)tableView
{
    self.selectedTableView.hidden = YES;
    [self.spinner stopAnimating];
    
    self.selectedTableView = tableView;
    self.selectedTableView.hidden = NO;
    
    self.contactsFailureLabel.hidden = YES;
    self.contactsPermissionLabel.hidden = YES;
    self.facebookConnectLabel.hidden = YES;
    
    if( tableView == self.contactsTableView )
    {
        if( self.isLoadingContacts )
        {
            [self.spinner startAnimating];
        }
        
        if( self.contactsFailure )
        {
            self.contactsFailureLabel.hidden = NO;
        }
        else if( self.contactsNotPermitted )
        {
            self.contactsPermissionLabel.hidden = NO;
        }
    }
    
    if( tableView == self.facebookTableView )
    {
        if( self.isLoadingFacebook )
        {
            [self.spinner startAnimating];
        }
        
        if( !self.isFacebookUser )
        {
            self.facebookConnectLabel.hidden = NO;
            [self.spinner stopAnimating];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if( tableView == self.contactsTableView )
    {
        count = self.registrationData.count;
    }
    else if( tableView == self.facebookTableView )
    {
        
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    NSDictionary *contact = self.registrationData[indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLightFont size:17.0];
    cell.textLabel.text = contact[kNameKey];
    
    BOOL invited = [contact[@"invited"] boolValue];
    
    if( invited )
    {
        [cell.sideButton setTitle:@"Invited" forState:UIControlStateNormal];
        [cell.sideButton setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
    }
    else
    {
        [cell.sideButton setTitle:@"Invite" forState:UIControlStateNormal];
        [cell.sideButton setTitleColor:[UIColor followButtonColor] forState:UIControlStateNormal];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    return cell;
}

- (void)sideButtonTappedOnFollowListTableViewCell:(DAUserListTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.contactsTableView indexPathForCell:cell];
    NSMutableDictionary *contact = [self.registrationData[indexPath.row] mutableCopy];
    
    if( [contact[@"invited"] boolValue] )
    {
        return;
    }
    
    [cell.sideButton setTitle:@"Invited" forState:UIControlStateNormal];
    [cell.sideButton setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
    
    NSArray *invites = @[ @{ kPhoneKey : contact[kPhoneKey] } ];
    
    NSDictionary *parameters = @{ kContactsKey : [self jsonEncodedStringWithArray:invites] };
    
    [[DAAPIManager sharedManager] POSTRequest:kUserContactsInviteURL withParameters:parameters success:nil
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self sideButtonTappedOnFollowListTableViewCell:cell];
        }
    }];
    
    contact[@"invited"] = @(YES);
    self.registrationData[indexPath.row] = contact;
}

- (IBAction)sourcePicked
{
    switch( self.sourcePicker.selectedSegmentIndex )
    {
        case 0: [self makeTableViewActive:self.contactsTableView]; break;
        case 1: [self makeTableViewActive:self.facebookTableView]; break;
    }
}

@end
//
//  DAInviteFriendsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 12/18/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAInviteFriendsViewController.h"
#import <AddressBook/AddressBook.h>


@interface DAInviteFriendsViewController()

@property (strong, nonatomic) NSArray     *contactsList;
@property (strong, nonatomic) UITableView *selectedTableView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

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
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    [self loadContacts];
}

- (void)loadContacts
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if( status == kABAuthorizationStatusDenied )
    {
        self.contactsNotPermitted = YES;
        return;
    }
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions( nil, &error );
    
    if( error )
    {
        self.contactsFailure = YES;
        return;
    }
    
    if( status == kABAuthorizationStatusNotDetermined )
    {
        ABAddressBookRequestAccessWithCompletion( addressBook, ^( bool granted, CFErrorRef error )
        {
            dispatch_async( dispatch_get_main_queue(), ^
            {
                if( error )
                {
                    self.contactsFailure = YES;
                }
                else if( !granted )
                {
                    self.contactsNotPermitted = YES;
                }
                else
                {
                    [self listPeopleInAddressBook:addressBook];
                }
                
                [self.contactsTableView reloadData];
                
                CFRelease( addressBook );
            });
        });
        
    }
    else if( status == kABAuthorizationStatusAuthorized )
    {
        [self listPeopleInAddressBook:addressBook];
        [self.contactsTableView reloadData];
        
        if( self.selectedTableView == self.contactsTableView )
        {
            [self.spinner stopAnimating];
        }

        CFRelease( addressBook );
    }
}

- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook
{
    NSInteger numberOfPeople = ABAddressBookGetPersonCount( addressBook );
    NSArray *allPeople = CFBridgingRelease( ABAddressBookCopyArrayOfAllPeople( addressBook ) );
    
    NSMutableArray *contacts = [NSMutableArray array];
    
    for( NSInteger i = 0; i < numberOfPeople; i++ )
    {
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue( person, kABPersonPhoneProperty );
        
        if( phoneNumbers )
        {
            CFIndex numberOfPhoneNumbers = ABMultiValueGetCount( phoneNumbers );
            
            NSCharacterSet *decimalCharacters = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            
            for( CFIndex i = 0; i < numberOfPhoneNumbers; i++ )
            {
                CFStringRef label = ABMultiValueCopyLabelAtIndex( phoneNumbers, i );
                NSString *phoneLabel = CFBridgingRelease( ABAddressBookCopyLocalizedLabel( label ) );
                
                if( [phoneLabel isEqualToString:@"mobile"] )
                {
                    NSString *phoneNumber = CFBridgingRelease( ABMultiValueCopyValueAtIndex( phoneNumbers, i ) );
                    NSString *number = [[phoneNumber componentsSeparatedByCharactersInSet:decimalCharacters] componentsJoinedByString: @""];
                    
                    NSString *firstName = CFBridgingRelease( ABRecordCopyValue( person, kABPersonFirstNameProperty ) );
                    NSString *lastName  = CFBridgingRelease( ABRecordCopyValue( person, kABPersonLastNameProperty  ) );
                    NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];

                    ABMutableMultiValueRef emailRef  = ABRecordCopyValue( person, kABPersonEmailProperty );
                    NSString *email = nil;
                    
                    if( ABMultiValueGetCount( emailRef ) > 0 )
                    {
                        email = CFBridgingRelease( ABMultiValueCopyValueAtIndex( emailRef, 0 ) );
                    }
                    
                    NSDictionary *contactDict = [self dictionaryWithName:name number:number email:email];
                    
                    [contacts addObject:contactDict];
                }
            }
            
            CFRelease( phoneNumbers );
        }
    }
    
    self.contactsList = contacts;
    NSLog(@"%@", self.contactsList);
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
    
    self.selectedTableView = tableView;
    self.selectedTableView.hidden = NO;
    
    self.contactsFailureLabel.hidden = YES;
    self.contactsPermissionLabel.hidden = YES;
    
    if( tableView == self.contactsTableView )
    {
        if( self.contactsFailure )
        {
            self.contactsFailureLabel.hidden = NO;
        }
        else if( self.contactsNotPermitted )
        {
            self.contactsPermissionLabel.hidden = NO;
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
        count = self.contactsList.count;
    }
    else if( tableView == self.facebookTableView )
    {
        
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell new];
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
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
@property (strong, nonatomic) NSArray     *selectedDataSource;
@property (strong, nonatomic) UITableView *selectedTableView;

@property (nonatomic) BOOL contactsFailure;
@property (nonatomic) BOOL contactsNotPermitted;

@end


@implementation DAInviteFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sourcePicker.tintColor = [UIColor dishedColor];
    
    self.selectedTableView = self.contactsTableView;
    self.facebookTableView.hidden = YES;
    
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
                else
                {
                    self.contactsNotPermitted = !granted;
                }
                
                if( !self.contactsNotPermitted )
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

        CFRelease( addressBook );
    }
}

- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook
{
    NSInteger numberOfPeople = ABAddressBookGetPersonCount( addressBook );
    NSArray *allPeople = CFBridgingRelease( ABAddressBookCopyArrayOfAllPeople( addressBook ) );
    
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
                    NSString *numbers = [[phoneNumber componentsSeparatedByCharactersInSet:decimalCharacters] componentsJoinedByString: @""];
                    
                    NSString *firstName = CFBridgingRelease( ABRecordCopyValue( person, kABPersonFirstNameProperty ) );
                    NSString *lastName  = CFBridgingRelease( ABRecordCopyValue( person, kABPersonLastNameProperty  ) );
                    NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                    
                    NSLog(@"%@ - %@", name, numbers);
                }
            }
            
            CFRelease( phoneNumbers );
        }
    }
}

- (void)makeTableViewActive:(UITableView *)tableView
{
    self.selectedTableView.hidden = YES;
    
    self.selectedTableView = tableView;
    self.selectedTableView.hidden = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectedDataSource.count;
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
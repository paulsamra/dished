//
//  AppDelegate.h
//  Dished
//
//  Created by Ryan Khalili on 6/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAContact.h"
#import <AddressBook/AddressBook.h>


@interface DAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (void)getContactsAddressBookWithCompletion:( void(^)( BOOL granted, ABAddressBookRef addressBook, NSError *error ) )completion;
+ (NSArray *)contactsWithAddressBook:(ABAddressBookRef)addressBook;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

- (void)login;
- (void)logout;
- (void)setRootView;
- (void)setLoginView;
- (void)followFacebookFriends;
- (void)followContacts;

@end
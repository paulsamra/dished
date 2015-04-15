//
//  AppDelegate.m
//  Dished
//
//  Created by Ryan Khalili on 6/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAAppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SSKeychain.h"
#import "DATwitterManager.h"
#import <Crashlytics/Crashlytics.h>
#import "DAUserManager.h"
#import "DACoreDataManager.h"
#import "DANewsManager.h"
#import "DAContainerViewController.h"
#import "UserVoice.h"
#import "DAPushManager.h"
#import "DALocationManager.h"
#import "DACacheManager.h"
#import "Mixpanel.h"

#define kMixpanelToken @"31ee3d271d65f678f84e52e66a8225b9"


@interface DAAppDelegate()

@property (strong, nonatomic) DAErrorView *errorView;

@end


@implementation DAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearance];
    
    [DAUserManager sharedManager];
    [DATwitterManager sharedManager];
    
    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlocked];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    if( [[DAAPIManager sharedManager] isLoggedIn] )
    {
        [self login];
        
        if( FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded )
        {
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_friends", @"email"] allowLoginUI:NO
            completionHandler:^( FBSession *session, FBSessionState state, NSError *error )
            {
                [self sessionStateChanged:session state:state error:error];
            }];
        }
        
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if ( userInfo )
        {
            [self application:application didReceiveRemoteNotification:userInfo];
        }
    }
    else
    {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachable) name:kNetworkReachableKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUnreachable) name:kNetworkUnreachableKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceLogout) name:kForcedLogoutNotificationKey object:nil];
    
    [Crashlytics startWithAPIKey:@"8553c9eeaaf67ce6f513e36c6cd30df3176d0664"];
    [Mixpanel sharedInstanceWithToken:kMixpanelToken];
    
    return YES;
}

- (void)setupUserVoice
{
    NSString *email = [DAUserManager sharedManager].email;
    NSString *name  = [NSString stringWithFormat:@"%@ %@", [DAUserManager sharedManager].firstName, [DAUserManager sharedManager].lastName];
    NSString *userID = [NSString stringWithFormat:@"%d", (int)[DAUserManager sharedManager].user_id];
    
    UVConfig *config = [UVConfig configWithSite:@"dishedapp.uservoice.com"];
    [config identifyUserWithEmail:email name:name guid:userID];
    [UserVoice initialize:config];
}

- (void)setupAppearance
{
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:18],
                                  NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:0.61 blue:1 alpha:1] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] } forState:UIControlStateDisabled];
    
    NSDictionary *titleAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18] };
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0 green:0.61 blue:1 alpha:1]];
    
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[[DACoreDataManager sharedManager] backgroundManagedContext] save:nil];
    [[[DACoreDataManager sharedManager] mainManagedContext] save:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if( [[url absoluteString] rangeOfString:kTwitterCallbackURL].location != NSNotFound )
    {
        [[DATwitterManager sharedManager] processURL:url];
        
        return YES;
    }
    
    if( [[url absoluteString] rangeOfString:@"com.dishedapp.dished"].location == NSNotFound )
    {        
        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication
        fallbackHandler:^( FBAppCall *call )
        {
            if( [[call appLinkData] targetURL] != nil )
            {
                NSString *objectId = [[[call appLinkData] targetURL].path substringFromIndex:1];
                
                [self handleFacebookLink:objectId];
            }
        }];
        
        return wasHandled;
    }
    
    return YES;
}

- (void)handleFacebookLink:(NSString *)url
{
    if( [[DAAPIManager sharedManager] isLoggedIn] )
    {
        NSArray *seperated = [url componentsSeparatedByString:@"/"];
        
        DAContainerViewController *rootViewController = (DAContainerViewController *)self.window.rootViewController;
        
        if( [seperated[0] isEqualToString:@"review"] )
        {
            NSInteger reviewID = [seperated[1] integerValue];
            [rootViewController openReviewWithReviewID:reviewID];
        }
        else if( [seperated[0] isEqualToString:@"dish"] )
        {
            NSInteger dishID = [seperated[1] integerValue];
            [rootViewController openDishWithDishID:dishID];
        }
    }
}

- (void)errorViewDidTapCloseButton:(DAErrorView *)errorView
{
    CGRect hiddenFrame = self.errorView.frame;
    hiddenFrame.origin.y -= 100;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        [self.errorView setFrame:hiddenFrame];
    }];
}

- (void)showErrorViewWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
{
    self.errorView.messageLabel.text = title;
    self.errorView.tipLabel.text  = subtitle;
    
    CGRect  statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    CGPoint location = statusBarRect.origin;
    CGFloat height = statusBarRect.size.height + 44;
    CGSize  size = CGSizeMake( self.window.frame.size.width, height );
    CGRect  visibleFrame = CGRectMake( location.x, location.y, size.width, size.height );
    
    [UIView animateWithDuration:0.5 animations:^
    {
        [self.errorView setFrame:visibleFrame];
    }];
}

- (void)networkReachable
{
    [self errorViewDidTapCloseButton:self.errorView];
}

- (void)networkUnreachable
{
    NSString *message = @"Unable to connect to network.";
    NSString *detail  = @"Please check your internet connection.";
    
    [self showErrorViewWithTitle:message subtitle:detail];
}

- (void)showMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if( !error && state == FBSessionStateOpen )
    {
        NSLog(@"User logged into Facebook.");
        return;
    }
    
    if( state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed )
    {
        NSLog(@"User not logged into Facebook.");
    }
    
    if( error )
    {
        NSLog(@"Facebook Error");
        NSString *alertText;
        NSString *alertTitle;
        
        // If the error requires people using an app to make an action outside of the app in order to recover
        if( [FBErrorUtility shouldNotifyUserForError:error] )
        {
            alertTitle = @"Something went wrong.";
            alertText = [FBErrorUtility userMessageForError:error];
        }
        else
        {
            // If the user cancelled login, do nothing
            if( [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled )
            {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            }
            else if( [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession )
            {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
            }
            else
            {
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }
        
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)setRootView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DAContainerViewController *containerViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"container"];
    
    self.window.rootViewController = containerViewController;
    
    [UIView transitionWithView:self.window
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

- (void)setLoginView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *loginView = [mainStoryboard instantiateViewControllerWithIdentifier:@"splashNav"];
    
//    DASplashViewController2 *splashViewController = [[DASplashViewController2 alloc] init];
//    UINavigationController *loginView = [[UINavigationController alloc] initWithRootViewController:splashViewController];
    
    self.window.rootViewController = loginView;
    
    [UIView transitionWithView:self.window
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

- (void)login
{
    [[DAUserManager sharedManager] loadUserInfoWithCompletion:nil];
    [[DANewsManager sharedManager] updateAllNews];
    [self setupUserVoice];
    [self setRootView];
    [self registerForPushNotifications];
}

- (void)registerForPushNotifications
{
    if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 )
    {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                                              UIRemoteNotificationTypeAlert |
                                                                              UIRemoteNotificationTypeSound];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSLog(@"My push token is: %@", hexToken);
    
    if( [[DAAPIManager sharedManager] isLoggedIn] )
    {
        NSDictionary *parameters = @{ kTokenKey : hexToken };
        
        [[DAAPIManager sharedManager] POSTRequest:kUserDeviceTokenURL withParameters:parameters success:nil
        failure:^( NSError *error, BOOL shouldRetry )
        {
            if( shouldRetry )
            {
                [self application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
            }
        }];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if( [[DAAPIManager sharedManager] isLoggedIn] )
    {        
        [DAPushManager handlePushNotification:userInfo];
    }
}

- (void)logout
{
    [self clearAllUserData];
    [self setLoginView];
}

- (void)clearAllUserData
{
    [[DAUserManager sharedManager] logout];
    [[DANewsManager sharedManager] deleteAllNews];
    [[DATwitterManager sharedManager] logout];
    [[DALocationManager sharedManager] stopUpdatingLocation];
    [[DACacheManager sharedManager] clearCaches];
    [[DACoreDataManager sharedManager] resetStore];
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)forceLogout
{
    [self logout];
    [[[UIAlertView alloc] initWithTitle:@"Session Expired" message:@"Please log in again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (DAErrorView *)errorView
{
    if( !_errorView )
    {
        CGRect  statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
        CGPoint location = statusBarRect.origin;
        CGFloat height = statusBarRect.size.height + 44;
        CGSize  size = CGSizeMake( self.window.frame.size.width, height );
        CGRect  hiddenFrame = CGRectMake( location.x, location.y - 100, size.width, size.height);
        
        _errorView = [[DAErrorView alloc] initWithFrame:hiddenFrame];
        [_errorView.closeButton addTarget:self action:@selector(errorViewDidTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.window addSubview:_errorView];
    }
    
    return _errorView;
}

- (void)followFacebookFriends
{
    if( ![[DAAPIManager sharedManager] isLoggedIn] )
    {
        return;
    }
    
    [[FBRequest requestForMyFriends] startWithCompletionHandler: ^( FBRequestConnection *connection, NSDictionary* result, NSError *error )
    {
        NSArray* friends = [result objectForKey:@"data"];
        
        NSMutableArray *friendsToFollow = [NSMutableArray new];
        
        for( NSDictionary<FBGraphUser>* friend in friends )
        {
            NSDictionary *dict = @{ @"fb_id" : friend.objectID };
            [friendsToFollow addObject:dict];
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:friendsToFollow options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSDictionary *parameters = @{ kContactsKey : jsonString };

        [[DAAPIManager sharedManager] POSTRequest:kUserContactsFollowURL withParameters:parameters success:nil failure:nil];
    }];
}

- (void)followContacts
{
    if( ![[DAAPIManager sharedManager] isLoggedIn] )
    {
        return;
    }
    
    [DAAppDelegate getContactsAddressBookWithCompletion:^( BOOL granted, ABAddressBookRef addressBook, NSError *error )
    {
        if( addressBook )
        {
            NSArray *contacts = [DAAppDelegate contactsWithAddressBook:addressBook];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contacts options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
            NSDictionary *parameters = @{ kContactsKey : jsonString };
            
            [[DAAPIManager sharedManager] POSTRequest:kUserContactsFollowURL withParameters:parameters success:nil failure:nil];
        }
    }];
}

+ (void)getContactsAddressBookWithCompletion:( void(^)( BOOL granted, ABAddressBookRef addressBook, NSError *error ) )completion
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if( status == kABAuthorizationStatusDenied )
    {
        completion( NO, nil, nil );
    }
    
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions( nil, &error );
    
    if( error )
    {
        completion( NO, nil, CFBridgingRelease( error ) );
    }
    
    if( status == kABAuthorizationStatusNotDetermined )
    {
        ABAddressBookRequestAccessWithCompletion( addressBook, ^( bool granted, CFErrorRef error )
        {
            dispatch_async( dispatch_get_main_queue(), ^
            {
                if( error )
                {
                    completion( NO, nil, CFBridgingRelease( error ) );
                }
                else if( !granted )
                {
                    completion( NO, nil, nil );
                }
                else
                {
                    completion( YES, addressBook, nil );
                    CFRelease( addressBook );
                }
            });
         });
    }
    else if( status == kABAuthorizationStatusAuthorized )
    {
        completion( YES, addressBook, nil );
        CFRelease( addressBook );
    }
}

+ (NSArray *)contactsWithAddressBook:(ABAddressBookRef)addressBook
{
    if( !addressBook )
    {
        return nil;
    }
    
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
                
                if( ![phoneLabel isEqualToString:@"home"] )
                {
                    NSString *phoneNumber = CFBridgingRelease( ABMultiValueCopyValueAtIndex( phoneNumbers, i ) );
                    NSString *number = [[phoneNumber componentsSeparatedByCharactersInSet:decimalCharacters] componentsJoinedByString: @""];
                    
                    if( number.length > 0 )
                    {
                        if( [number characterAtIndex:0] == '1' )
                        {
                            number = [number substringFromIndex:1];
                        }
                    }
                    
                    if( number.length != 10 )
                    {
                        continue;
                    }
                    
                    NSString *firstName = CFBridgingRelease( ABRecordCopyValue( person, kABPersonFirstNameProperty ) );
                    firstName = firstName ? firstName : @"";
                    NSString *lastName  = CFBridgingRelease( ABRecordCopyValue( person, kABPersonLastNameProperty  ) );
                    lastName = lastName ? lastName : @"";
                    NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                    
                    ABMutableMultiValueRef emailRef  = ABRecordCopyValue( person, kABPersonEmailProperty );
                    NSString *email = nil;
                    
                    if( ABMultiValueGetCount( emailRef ) > 0 )
                    {
                        email = CFBridgingRelease( ABMultiValueCopyValueAtIndex( emailRef, 0 ) );
                    }
                    
                    NSDictionary *contactDict = [DAAppDelegate dictionaryWithName:name number:number email:email];
                    [contacts addObject:contactDict];
                    break;
                }
            }
            
            CFRelease( phoneNumbers );
        }
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortedContacts = [contacts sortedArrayUsingDescriptors:@[ descriptor ]];
    
    return sortedContacts;
}

+ (NSDictionary *)dictionaryWithName:(NSString *)name number:(NSString *)number email:(NSString *)email
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

@end
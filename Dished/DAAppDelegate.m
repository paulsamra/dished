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


@interface DAAppDelegate()

@end


@implementation DAAppDelegate
            
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearance];
    
    [DATwitterManager sharedManager];
    
    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlocked];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    if( FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded )
    {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:NO
        completionHandler:^( FBSession *session, FBSessionState state, NSError *error )
        {
            [self sessionStateChanged:session state:state error:error];
        }];
    }
    
    return YES;
}

- (void)setupAppearance
{
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:18],
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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
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
        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        
        return wasHandled;
    }
    
    return YES;
}

- (void)showMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        NSLog(@"Session opened");
        return;
    }
    
    if( state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed )
    {
        NSLog(@"Session closed");
    }
    
    // Handle errors
    if( error )
    {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //[self showMessage:alertText withTitle:alertTitle];
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
                //[self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            }
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                //[self showMessage:alertText withTitle:alertTitle];
            }
        }
        
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];        
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Dished" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Dished.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)setRootView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UITabBarController *mainTabs = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabs"];
    
    self.window.rootViewController = mainTabs;
    
    [UIView transitionWithView:self.window
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

@end

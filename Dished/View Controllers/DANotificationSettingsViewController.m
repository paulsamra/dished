//
//  DANotificationSettingsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANotificationSettingsViewController.h"
#import "DAUserManager.h"


@interface DANotificationSettingsViewController()

@end


@implementation DANotificationSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self populateSetting];
}

- (void)populateSetting
{
    if( [self.notificationType isEqualToString:@"yum"] )
    {
        self.title = @"YUM Notifications";
        [self selectRowWithPushSetting:[DAUserManager sharedManager].receivesYumPushNotifications];
    }
    else if( [self.notificationType isEqualToString:@"comment"] )
    {
        self.title = @"Comment Notifications";
        [self selectRowWithPushSetting:[DAUserManager sharedManager].receivesCommentPushNotifications];
    }
    else if( [self.notificationType isEqualToString:@"review"] )
    {
        self.title = @"New Review Notifications";
        [self selectRowWithPushSetting:[DAUserManager sharedManager].receivesReviewPushNotifications];
    }
}

- (void)selectRowWithPushSetting:(ePushSetting)pushSetting
{
    switch( pushSetting )
    {
        case ePushSettingOff:      self.offCell.accessoryType      = UITableViewCellAccessoryCheckmark; break;
        case ePushSettingFollowed: self.followCell.accessoryType   = UITableViewCellAccessoryCheckmark; break;
        case ePushSettingEveryone: self.everyoneCell.accessoryType = UITableViewCellAccessoryCheckmark; break;
    }
}

- (void)deselectAllRows
{
    self.offCell.accessoryType      = UITableViewCellAccessoryNone;
    self.followCell.accessoryType   = UITableViewCellAccessoryNone;
    self.everyoneCell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch( indexPath.row )
    {
        case 0: [self selectedPushSetting:ePushSettingOff];      break;
        case 1: [self selectedPushSetting:ePushSettingFollowed]; break;
        case 2: [self selectedPushSetting:ePushSettingEveryone]; break;
    }
}
                 
- (void)selectedPushSetting:(ePushSetting)pushSetting
{
    [self deselectAllRows];
    
    [self selectRowWithPushSetting:pushSetting];
    
    if( [self.notificationType isEqualToString:@"yum"] )
    {
        [[DAUserManager sharedManager] setYumPushNotificationSetting:pushSetting completion:^( BOOL success )
        {
            [self populateSetting];
        }];
    }
    else if( [self.notificationType isEqualToString:@"comment"] )
    {
        [[DAUserManager sharedManager] setCommentPushNotificationSetting:pushSetting completion:^( BOOL success )
        {
            [self populateSetting];
        }];
    }
    else if( [self.notificationType isEqualToString:@"review"] )
    {
        [[DAUserManager sharedManager] setReviewPushNotificationSetting:pushSetting completion:^( BOOL success )
        {
            [self populateSetting];
        }];
    }
}

@end
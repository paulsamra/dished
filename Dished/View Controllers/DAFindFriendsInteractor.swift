//
//  DAFindFriendsInteractor.swift
//  Dished
//
//  Created by Ryan Khalili on 3/24/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import Foundation
import MessageUI

protocol DAFindFriendsInteractorDelegate: class {
    func findFriendsInteractorDidFinishSendingMessage(interactor: DAFindFriendsInteractor)
}

class DAFindFriendsInteractor: NSObject, MFMessageComposeViewControllerDelegate {
    
    weak var delegate: DAFindFriendsInteractorDelegate?
    private var friendComposers = [MFMessageComposeViewController:DAFriend]()
    
    func messageComposerForFriend(friend: DAFriend) -> MFMessageComposeViewController? {
        if !MFMessageComposeViewController.canSendText() {
            return nil
        }
        
        let recipients = [friend.phoneNumber]
        let messageController = MFMessageComposeViewController()
        messageController.recipients = recipients
        messageController.messageComposeDelegate = self
        
        friendComposers[messageController] = friend
        
        return messageController
    }
    
    init(delegate: DAFindFriendsInteractorDelegate?) {
        self.delegate = delegate
        super.init()
    }
    
    func doFollowInteractionForFriend(friend: DAFriend) {
        if !friend.registered {
            return
        }
        
        if friend.following {
            DAAPIManager.unfollowUserID(friend.userID)
        }
        else {
            DAAPIManager.followUserID(friend.userID)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        let friend = friendComposers[controller]
        
        if friend == nil {
            return
        }
        
        if friend!.registered {
            return
        }
        
        if result.value == MessageComposeResultFailed.value || result.value == MessageComposeResultCancelled.value {
            friend!.invited == false
        }
        else {
            friend!.invited = true
            markFriendAsInvited(friend!)
        }
        
        delegate?.findFriendsInteractorDidFinishSendingMessage(self)
        friendComposers[controller] = nil
    }
    
    private func markFriendAsInvited(friend: DAFriend) {
        if friend.invited || friend.registered {
            return
        }
        
        let invites = [[kPhoneKey: friend.phoneNumber]]
        let options = NSJSONWritingOptions.PrettyPrinted
        let jsonData = NSJSONSerialization.dataWithJSONObject(invites, options: options, error: nil)
        
        if jsonData == nil {
            return
        }
        
        let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding) as! String
        let parameters = [kContactsKey: jsonString]
        
        DAAPIManager.sharedManager().POSTRequest(kUserContactsInviteURL, withParameters: parameters, success: nil,
        failure: {
            error, shouldRetry in
            if shouldRetry {
                self.markFriendAsInvited(friend)
            }
        })
    }
}
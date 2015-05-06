//
//  UIViewController+Dished.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import Foundation

let IS_IOS8 = ( ( ( UIDevice.currentDevice().systemVersion as NSString ).floatValue >= 8.0 ) ? true : false )

extension UIViewController {
    
    var mainStoryboard: UIStoryboard? {
        get {
            return UIStoryboard(name: "Main", bundle: nil)
        }
    }
    
    func showAlertWithTitle( title: String?, message: String? )
    {
        if IS_IOS8
        {
            let alertView = UIAlertController( title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert )
            let alertAction = UIAlertAction( title: "OK", style: UIAlertActionStyle.Default, handler: nil )
            alertView.addAction( alertAction )
            
            self.presentViewController( alertView, animated: true, completion: nil )
        }
        else
        {
            let alertView = UIAlertView( title: title, message: message, delegate: nil, cancelButtonTitle: "OK" )            
            alertView.show()
        }
    }
    
    private func target() -> AnyObject?
    {
        return self.isKindOfClass( UINavigationController.self ) ? self : self.navigationController
    }
    
    func pushRestaurantProfileWithLocationID( locationID: Int, username: String? )
    {
        let userProfileViewController = viewControllerWithStoryboardID( kUserProfileID ) as! DAUserProfileViewController
        userProfileViewController.loc_id = locationID
        userProfileViewController.username = username
        userProfileViewController.isRestaurant = true
        
        target()?.pushViewController( userProfileViewController, animated: true )
    }
    
    func pushrestaurantProfileWithUserID( userID: Int, username: String? )
    {
        let userProfileViewController = viewControllerWithStoryboardID( kUserProfileID ) as! DAUserProfileViewController
        userProfileViewController.user_id = userID
        userProfileViewController.username = username
        userProfileViewController.isRestaurant = true
        
        target()?.pushViewController( userProfileViewController, animated: true )
    }
    
    func pushUserProfileWithUsername( username: String )
    {
        let userProfileViewController = viewControllerWithStoryboardID( kUserProfileID ) as! DAUserProfileViewController
        userProfileViewController.username = username
        userProfileViewController.isRestaurant = false
        
        target()?.pushViewController( userProfileViewController, animated: true )
    }
    
    func pushUserProfileWithUserID( userID: Int )
    {
        let userProfileViewController = viewControllerWithStoryboardID( kUserProfileID ) as! DAUserProfileViewController
        userProfileViewController.user_id = userID
        userProfileViewController.isRestaurant = false
        
        target()?.pushViewController( userProfileViewController, animated: true )
    }
    
    func pushReviewDetailsViewWithReviewID( reviewID: Int )
    {
        let reviewDetailsViewController = viewControllerWithStoryboardID( kReviewDetailsID ) as! DAReviewDetailsViewController
        reviewDetailsViewController.reviewID = reviewID
        
        target()?.pushViewController( reviewDetailsViewController, animated: true )
    }
    
    func pushGlobalDishViewWithDishID( dishID: Int )
    {
        let globalDishViewController = viewControllerWithStoryboardID( kGlobalDishID ) as! DAGlobalDishDetailViewController
        globalDishViewController.dishID = dishID
        
        target()?.pushViewController( globalDishViewController, animated: true )
    }
    
    func pushCommentsViewWithFeedItem( feedItem: DAFeedItem, showKeyboard: Bool )
    {
        let commentsViewController = viewControllerWithStoryboardID( kCommentsViewID ) as! DACommentsViewController
        commentsViewController.feedItem = feedItem
        commentsViewController.shouldShowKeyboard = showKeyboard
        
        target()?.pushViewController( commentsViewController, animated: true )
    }
    
    func pushCommentsViewWithReviewID( reviewID: Int, showKeyboard: Bool )
    {
        let commentsViewController = viewControllerWithStoryboardID( kCommentsViewID ) as! DACommentsViewController
        commentsViewController.reviewID = reviewID
        commentsViewController.shouldShowKeyboard = showKeyboard
        
        target()?.pushViewController( commentsViewController, animated: true )
    }
    
    func pushSettingsView() {
//        let settingsViewController = DASettingsViewController2()
        let settingsViewController = viewControllerWithStoryboardID( kSettingsViewID )
        target()?.pushViewController( settingsViewController, animated: true )
    }
    
    private func viewControllerWithStoryboardID(storyboardID: String) -> UIViewController! {
        return self.mainStoryboard?.instantiateViewControllerWithIdentifier( storyboardID ) as! UIViewController
    }
    
    func adjustInsetsForScrollView(scrollView: UIScrollView) {
        if navigationController?.navigationBar != nil {
            let navigationBarFrame = navigationController!.navigationBar.bounds
            let tableViewInset = UIApplication.sharedApplication().statusBarFrame.size.height + navigationBarFrame.size.height
            scrollView.contentInset = UIEdgeInsetsMake(tableViewInset, 0, 0, 0)
            scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewInset, 0, 0, 0)
        }
    }
}
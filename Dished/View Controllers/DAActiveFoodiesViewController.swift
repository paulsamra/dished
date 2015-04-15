//
//  DAActiveFoodiesViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAActiveFoodiesViewController: DAViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DADataSourceDelegate, DAFoodieCollectionViewCellDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    let cellIdentifier = "activeFoodieCell"
    var activeFoodiesView: DAActiveFoodiesView!
    var foodiesDataSource = DAActiveFoodiesDataSource()
    var searchController: UISearchDisplayController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Active Foodies"
        
        activeFoodiesView.collectionView.registerClass(DAFoodieCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        activeFoodiesView.collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "searchHeader")
        
        searchController.searchResultsTableView.registerClass(DAUserTableViewCell.self, forCellReuseIdentifier: "userCell")
        
        foodiesDataSource.delegate = self
        activeFoodiesView.searchBar.delegate = self
        loadFoodies()
    }
    
    func loadFoodies() {
        activeFoodiesView.showSpinner()
        foodiesDataSource.loadData()
    }
    
    deinit {
        foodiesDataSource.cancelLoadingData()
    }
    
    func dataSourceDidFailToLoadData(dataSource: DADataSource, withError error: NSError?) {
        activeFoodiesView.hideSpinner()
    }
    
    func dataSourceDidFinishLoadingData(dataSource: DADataSource) {
        activeFoodiesView.hideSpinner()
        activeFoodiesView.collectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodiesDataSource.foodies.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! DAFoodieCollectionViewCell
        
        let foodie = foodiesDataSource.foodies[indexPath.row]
        
        cell.configureWithFoodie(foodie)
        cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.followButton.addTarget(self, action: "followButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "searchHeader", forIndexPath: indexPath) as! UICollectionReusableView
        
        if let searchBar = searchDisplayController?.searchBar {
            searchBar.sizeToFit()
            reusableView.addSubview(searchBar)
            reusableView.sizeToFit()
        }
        
        return reusableView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(view.frame.size.width, 44.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(view.frame.size.width, 175.0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodiesDataSource.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! DAUserTableViewCell
        
        let foodie = foodiesDataSource.users[indexPath.row]
        cell.configureWithFoodie(foodie)
        cell.sideButton.addTarget(self, action: "cellButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let foodie = foodiesDataSource.users[indexPath.row]
        pushUserProfileWithUserID(foodie.userID)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        foodiesDataSource.loadUsersWithQuery(searchText, completion: {
            self.searchController.searchResultsTableView.reloadData()
        })
    }
    
    func cellButtonPressed(button: UIButton) {
        if let indexPath = searchController.searchResultsTableView.indexPathForView(button) {
            let foodie = foodiesDataSource.users[indexPath.row]
            
            if foodie.following {
                DAAPIManager.unfollowUserID(foodie.userID)
            }
            else {
                DAAPIManager.followUserID(foodie.userID)
            }
            
            foodie.following = !foodie.following
            searchController.searchResultsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        foodiesDataSource.resetUsersData()
    }
    
    func followButtonTapped(button: UIButton) {
        if let indexPath = activeFoodiesView.collectionView.indexPathForView(button) {
            let foodie = foodiesDataSource.foodies[indexPath.row]
            
            if foodie.following {
                DAAPIManager.unfollowUserID(foodie.userID)
            }
            else {
                DAAPIManager.followUserID(foodie.userID)
            }
            
            foodie.following = !foodie.following
            activeFoodiesView.collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }
    
    func cellDidSwipeAway(cell: DAFoodieCollectionViewCell) {
        if let indexPath = activeFoodiesView.collectionView.indexPathForCell(cell) {
            activeFoodiesView.collectionView.performBatchUpdates({
                self.foodiesDataSource.foodies.removeAtIndex(indexPath.row)
                self.activeFoodiesView.collectionView.deleteItemsAtIndexPaths([indexPath])
            }, completion: nil)
        }
    }
    
    func didTapImageAtIndex(index: Int, inFoodieCollectionViewCell cell: DAFoodieCollectionViewCell) {
        if let indexPath = activeFoodiesView.collectionView.indexPathForCell(cell) {
            let foodie = foodiesDataSource.foodies[indexPath.row]
            let review = foodie.reviews[index]
            pushReviewDetailsViewWithReviewID(review.reviewID)
        }
    }
    
    func usernameTapped(button: UIButton) {
        if let indexPath = activeFoodiesView.collectionView.indexPathForView(button) {
            let foodie = foodiesDataSource.foodies[indexPath.row]
            goToFoodieProfile(foodie)
        }
    }
    
    private func goToFoodieProfile(foodie: DAFoodie) {
        pushUserProfileWithUserID(foodie.userID)
    }
    
    override func loadView() {
        activeFoodiesView = DAActiveFoodiesView()
        activeFoodiesView.collectionView.dataSource = self
        activeFoodiesView.collectionView.delegate = self
        
        view = activeFoodiesView
        searchController = UISearchDisplayController(searchBar: activeFoodiesView.searchBar, contentsController: self)
        searchController.searchResultsDelegate = self
        searchController.searchResultsDataSource = self
    }
}
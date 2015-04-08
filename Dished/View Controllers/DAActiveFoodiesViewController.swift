//
//  DAActiveFoodiesViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAActiveFoodiesViewController: DAViewController, UICollectionViewDataSource, DADataSourceDelegate, DAFoodieCollectionViewCellDelegate, UISearchBarDelegate {

    let cellIdentifier = "activeFoodieCell"
    var activeFoodiesView: DAActiveFoodiesView!
    var foodiesDataSource = DAActiveFoodiesDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Active Foodies"
        
        activeFoodiesView.collectionView.registerClass(DAFoodieCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
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
        return foodiesDataSource.foodies.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as DAFoodieCollectionViewCell
        
        let foodie = foodiesDataSource.foodies[indexPath.row]
        
        cell.configureWithFoodie(foodie)
        cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.followButton.addTarget(self, action: "followButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.delegate = self
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        foodiesDataSource.reloadDataWithQuery(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
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
        
        view = activeFoodiesView
    }
}
//
//  DAActiveFoodiesViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAActiveFoodiesViewController: DAViewController, UICollectionViewDataSource, DADataSourceDelegate, DAFoodieCollectionViewCellDelegate {

    let cellIdentifier = "activeFoodieCell"
    var activeFoodiesView: DAActiveFoodiesView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Active Foodies"
        
        activeFoodiesView.collectionView.registerClass(DAFoodieCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        dataSource = DAActiveFoodiesDataSource(delegate: self)
        activeFoodiesView.showSpinner()
        dataSource?.loadData()
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
        return dataSource?.data.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as DAFoodieCollectionViewCell
        
        let foodie = dataSource?.data[indexPath.row] as DAFoodie
        
        cell.configureWithFoodie(foodie)
        cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.delegate = self
        
        return cell
    }
    
    func followButtonTapped(button: UIButton) {
        let indexPath = activeFoodiesView.collectionView.indexPathForView(button)
        if indexPath == nil {
            return
        }
        
        let foodie = dataSource?.data[indexPath!.row] as DAFoodie
        
    }
    
    func didTapImageAtIndex(index: Int, inFoodieCollectionViewCell cell: DAFoodieCollectionViewCell) {
        if let indexPath = activeFoodiesView.collectionView.indexPathForCell(cell) {
            let foodie = dataSource?.data[indexPath.row] as DAFoodie
            let review = foodie.reviews[index]
            pushReviewDetailsViewWithReviewID(review.reviewID)
        }
    }
    
    func usernameTapped(button: UIButton) {
        let indexPath = activeFoodiesView.collectionView.indexPathForView(button)
        if indexPath == nil {
            return
        }
        
        let foodie = dataSource?.data[indexPath!.row] as DAFoodie
        goToFoodieProfile(foodie)
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
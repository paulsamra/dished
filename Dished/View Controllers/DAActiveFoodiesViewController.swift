//
//  DAActiveFoodiesViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAActiveFoodiesViewController: DAViewController, UICollectionViewDataSource, DADataSourceDelegate {

    let cellIdentifier = "activeFoodieCell"
    var activeFoodiesView: DAActiveFoodiesView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Active Foodies"
        
        activeFoodiesView.collectionView.registerClass(DAFoodieCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        dataSource = DAActiveFoodiesDataSource()
        dataSource?.delegate = self
        
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
        
        cell.usernameButton.setTitle("@\(foodie.username)", forState: UIControlState.Normal)
        cell.descriptionLabel.text = foodie.description
        cell.followButton.setTitle("Follow", forState: UIControlState.Normal)
        cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let url = NSURL(string: foodie.image)
        cell.userImageView.sd_setImageWithURL(url)
        
        for (index, review) in enumerate(foodie.reviews) {
            if index < cell.reviewImageViews.count {
                let url = NSURL(string: review)
                cell.reviewImageViews[index].sd_setImageWithURL(url)
            }
        }
        
        return cell
    }
    
    func usernameTapped(button: UIButton) {
        let indexPath = activeFoodiesView.collectionView.indexPathForView(button)
        if indexPath == nil {
            return
        }
        
        if let foodie = dataSource?.data[indexPath!.row] as? DAFoodie {
            goToFoodieProfile(foodie)
            println(foodie.username)
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
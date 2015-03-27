//
//  DAActiveFoodiesViewController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAActiveFoodiesViewController: DAViewController, UICollectionViewDataSource {

    var activeFoodiesView: DAActiveFoodiesView!
    var foodies: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Active Foodies"
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodies?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    override func loadView() {
        activeFoodiesView = DAActiveFoodiesView()
        activeFoodiesView.collectionView.dataSource = self
        
        view = activeFoodiesView
    }
}
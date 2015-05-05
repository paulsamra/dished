//
//  DAActiveFoodiesView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAActiveFoodiesView: DALoadingView {
    
    var collectionView: UICollectionView!
    var searchBar: UISearchBar!
    
    private let searchBarHeight: CGFloat = 44.0
    private var topSearchBarConstraint: NSLayoutConstraint!
    
    override func showSpinner() {
        super.showSpinner()
        searchBar.hidden = true
        collectionView.hidden = true
    }
    
    override func hideSpinner() {
        super.hideSpinner()
        searchBar.hidden = false
        collectionView.hidden = false
    }
    
    override func setupViews() {        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor(r: 249, g: 249, b: 249, a: 255)
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
        addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        searchBar = UISearchBar()
        searchBar.barTintColor = UIColor(r: 242, g: 242, b: 242, a: 255)
        searchBar.placeholder = "Search for a user"
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(r: 220, g: 220, b: 220, a: 255).CGColor
    }
}
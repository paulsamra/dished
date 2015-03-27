//
//  DAActiveFoodiesView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAActiveFoodiesView: DAView {
    
    var collectionView: UICollectionView!
    
    override func setupViews() {
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
}
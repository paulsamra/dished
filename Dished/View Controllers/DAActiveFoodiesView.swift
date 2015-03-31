//
//  DAActiveFoodiesView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/26/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAActiveFoodiesView: DALoadingView, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    
    override func showSpinner() {
        super.showSpinner()
        collectionView.hidden = true
    }
    
    override func hideSpinner() {
        super.hideSpinner()
        collectionView.hidden = false
    }
    
    override func setupViews() {        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(r: 249, g: 249, b: 249, a: 255)
        collectionView.alwaysBounceVertical = true
        addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(frame.size.width, 175.0)
    }
}
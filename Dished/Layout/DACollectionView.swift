//
//  DACollectionView.swift
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit


class DACollectionView: UICollectionView
{
    override func touchesShouldCancelInContentView(view: UIView!) -> Bool
    {
        return true;
    }
}
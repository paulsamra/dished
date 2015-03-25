//
//  DACollectionViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 3/25/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DACollectionViewCell: UICollectionViewCell {
    
    override init() {
        super.init()
        setupViews()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
    
    }
}
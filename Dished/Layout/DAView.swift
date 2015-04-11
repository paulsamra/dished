//
//  DAView.swift
//  Dished
//
//  Created by Ryan Khalili on 3/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.whiteColor()
        setupViews()
    }
    
    func setupViews() {
        
    }
}
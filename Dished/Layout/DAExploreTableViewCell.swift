//
//  DAExploreTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 4/9/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAExploreTableViewCell: DATableViewCell {

    var iconImageView: UIImageView!
    var nameLabel: UILabel!
    
    private let iconImageSize = CGSizeMake(25.0, 25.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2.0
    }
    
    override func setupViews() {
        iconImageView = UIImageView()
        iconImageView.layer.masksToBounds = true
        addSubview(iconImageView)
        iconImageView.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 10.0)
        iconImageView.autoSetDimensionsToSize(iconImageSize)
        iconImageView.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        addSubview(nameLabel)
        nameLabel.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        nameLabel.autoSetDimension(ALDimension.Height, toSize: 20.0)
        nameLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: iconImageView, withOffset: 8)
        nameLabel.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 8.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
        nameLabel.text = nil
    }
}
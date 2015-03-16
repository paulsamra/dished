//
//  DADishSuggestionsTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DADishSuggestionTableViewCell: DATableViewCell
{
    var nameLabel: UILabel!
    var placeLabel: UILabel!
    
    override func setupViews() {
        let locationImageView = UIImageView(image: UIImage(named: "dish_location"))
        addSubview(locationImageView)
        locationImageView.autoSetDimensionsToSize(CGSizeMake(10, 15))
        locationImageView.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        locationImageView.autoAlignAxis(ALAxis.Vertical, toSameAxisOfView: self, withOffset: 55.0)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 17.0)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        addSubview(nameLabel)
        nameLabel.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 20.0)
        nameLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 7)
        nameLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 6)
        nameLabel.autoPinEdge(ALEdge.Right, toEdge: ALEdge.Left, ofView: locationImageView, withOffset: -8)
        
        placeLabel = UILabel()
        placeLabel.font = UIFont(name: kHelveticaNeueLightFont, size: 11.0)
        placeLabel.numberOfLines = 0
        placeLabel.textColor = UIColor.lightGrayColor()
        placeLabel.adjustsFontSizeToFitWidth = false
        addSubview(placeLabel)
        placeLabel.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 7)
        placeLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 9)
        placeLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 9)
        placeLabel.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: locationImageView, withOffset: 8)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        placeLabel.text = ""
    }
}
//
//  DAReviewHeaderCollectionReusableView.swift
//  Dished
//
//  Created by Ryan Khalili on 12/25/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit


@objc protocol DADishHeaderCollectionReusableViewDelegate {
    optional func titleButtonTappedOnFeedHeaderCollectionReusableView(cell: DADishHeaderCollectionReusableView)
}

class DADishHeaderCollectionReusableView: UICollectionReusableView {
    
    weak var delegate: DADishHeaderCollectionReusableViewDelegate?
    
    var titleButton: UIButton!
    var sideLabel: UILabel!
    
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
    
    func titleButtonTapped() {
        delegate?.titleButtonTappedOnFeedHeaderCollectionReusableView?(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sideLabel.text = ""
        titleButton .setTitle("", forState: UIControlState.Normal)
    }
    
    func setupViews() {
        backgroundColor = UIColor(r: 249, g: 249, b: 249, a: 242)
        let textColor = UIColor(r: 95, g: 100, b: 114, a: 255)
        
        sideLabel = UILabel()
        sideLabel.textColor = textColor
        sideLabel.font = DAConstants.primaryFontWithSize(17.0)
        sideLabel.adjustsFontSizeToFitWidth = true
        sideLabel.minimumScaleFactor = 0.75
        sideLabel.textAlignment = NSTextAlignment.Right
        addSubview(sideLabel)
        sideLabel.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 6.0)
        sideLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top)
        sideLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        sideLabel.autoSetDimension(ALDimension.Width, toSize: 52.0)
        
        titleButton = UIButton()
        titleButton.titleLabel?.font = DAConstants.primaryFontWithSize(20.0)
        titleButton.setTitleColor(textColor, forState: UIControlState.Normal)
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.75
        titleButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
        titleButton.addTarget( self, action: "titleButtonTapped", forControlEvents: UIControlEvents.TouchUpInside )
        addSubview(titleButton)
        titleButton.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 10.0)
        titleButton.autoPinEdgeToSuperviewEdge(ALEdge.Top)
        titleButton.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        titleButton.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Leading, ofView: sideLabel, withOffset: -12.0, relation: NSLayoutRelation.LessThanOrEqual)
        
        let borderView = UIView()
        borderView.backgroundColor = UIColor(r: 212, g: 210, b: 220, a: 255)
        addSubview(borderView)
        borderView.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        borderView.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        borderView.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        borderView.autoSetDimension(ALDimension.Height, toSize: 1.0)
    }
}
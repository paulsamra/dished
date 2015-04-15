//
//  DAReviewDetailCollectionViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

@objc protocol DAReviewDetailCollectionViewCellDelegate {
    optional func textViewTappedOnText( text: String, withTextType textType: eLinkedTextType, inCell cell: DAReviewDetailCollectionViewCell )
}

class DAReviewDetailCollectionViewCell: DACollectionViewCell, DALinkedTextViewDelegate {
    
    weak var delegate: DAReviewDetailCollectionViewCellDelegate?
    
    var iconImageView: UIImageView!
    var textView: DALinkedTextView!
    
    class func sizingCell() -> DAReviewDetailCollectionViewCell {
        let cell = DAReviewDetailCollectionViewCell(frame: CGRectMake(0.0, 0.0, 320.0, 50.0))
        cell.layoutIfNeeded()
        return cell
    }
    
    func linkedTextView( textView: DALinkedTextView!, tappedOnText text: String!, withLinkedTextType textType: eLinkedTextType ) {
        if text != nil {
            delegate?.textViewTappedOnText?( text, withTextType: textType, inCell: self )
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.hidden = false
        iconImageView.image = nil
        textView.text = nil
        textView.attributedText = nil
    }
    
    override func setupViews() {
        iconImageView = UIImageView()
        iconImageView.contentMode = UIViewContentMode.ScaleAspectFill
        iconImageView.clipsToBounds = true
        addSubview(iconImageView)
        iconImageView.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 9.0)
        iconImageView.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 4.0)
        iconImageView.autoSetDimensionsToSize(CGSizeMake(12.0, 11.0))
        
        textView = DALinkedTextView()
        textView.font = DAConstants.primaryFontWithSize(14.0)
        textView.selectable = false
        textView.editable = false
        textView.scrollsToTop = false
        textView.textContainerInset = UIEdgeInsetsZero
        textView.tapDelegate = self
        textView.backgroundColor = UIColor.clearColor()
        addSubview(textView)
        textView.autoPinEdgeToSuperviewEdge(ALEdge.Top)
        textView.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        textView.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 15.0)
        textView.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: iconImageView, withOffset: 2.0)
    }
}
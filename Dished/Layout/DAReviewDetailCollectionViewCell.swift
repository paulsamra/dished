//
//  DAReviewDetailCollectionViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

@objc protocol DAReviewDetailCollectionViewCellDelegate
{
    optional func textViewTappedOnText( text: String, withTextType: eLinkedTextType, inCell: DAReviewDetailCollectionViewCell )
}

class DAReviewDetailCollectionViewCell: UICollectionViewCell, DALinkedTextViewDelegate
{
    weak var delegate: DAReviewDetailCollectionViewCellDelegate?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textView: DALinkedTextView!
    
    class func sizingCell() -> DAReviewDetailCollectionViewCell
    {
        let nibName = "DAReviewDetailCollectionViewCell"
        let loadedNib = NSBundle.mainBundle().loadNibNamed( nibName, owner: self, options: nil )
        return loadedNib.last as DAReviewDetailCollectionViewCell
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        textView.scrollsToTop = false
        textView.textContainerInset = UIEdgeInsetsZero
        textView.tapDelegate = self
    }
    
    func linkedTextView( textView: DALinkedTextView!, tappedOnText text: String!, withLinkedTextType textType: eLinkedTextType )
    {
        if( text != nil )
        {
            delegate?.textViewTappedOnText?( text, withTextType: textType, inCell: self )
        }
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        iconImageView.hidden = false
        iconImageView.image = nil
        textView.text = nil
        textView.attributedText = nil
    }
}
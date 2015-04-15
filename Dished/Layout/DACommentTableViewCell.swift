//
//  DACommentTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit


@objc protocol DACommentTableViewCellDelegate {
    optional func textViewTapped( text: String, textType: eLinkedTextType, inCell: DACommentTableViewCell )
}

class DACommentTableViewCell: SWTableViewCell, DALinkedTextViewDelegate {
    
    var textViewTapDelegate: DACommentTableViewCellDelegate?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentTextView: DALinkedTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.layer.masksToBounds = true
        
        commentTextView.tapDelegate = self
        
        commentTextView.textContainerInset = UIEdgeInsetsZero
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.image = nil
        commentTextView.attributedText = nil
        commentTextView.text = nil
    }
    
    func linkedTextView( textView: DALinkedTextView!, tappedOnText text: String!, withLinkedTextType textType: eLinkedTextType ) {
        if text != nil {
            textViewTapDelegate?.textViewTapped?( text, textType: textType, inCell: self )
        }
    }
}
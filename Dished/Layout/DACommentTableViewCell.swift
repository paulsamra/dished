//
//  DACommentTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 9/22/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit


@objc protocol DACommentTableViewCellDelegate
{
    optional func textViewTapped( characterIndex: Int, cell: DACommentTableViewCell )
}

class DACommentTableViewCell: SWTableViewCell
{
    var textViewTapDelegate: DACommentTableViewCellDelegate?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentTextView: DALinkedTextView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = true;
        
        commentTextView.textContainerInset = UIEdgeInsetsZero
        
        let tapGesture = UITapGestureRecognizer( target: self, action: "textViewTapped:" )
        tapGesture.numberOfTapsRequired = 1
        self.commentTextView.addGestureRecognizer( tapGesture )
    }
    
    func textViewTapped( recognizer: UITapGestureRecognizer )
    {
        let textView = recognizer.view as UITextView
        
        let layoutManager = textView.layoutManager
        var location = recognizer.locationInView( textView )
        location.x = location.x - textView.textContainerInset.left
        location.y = location.y - textView.textContainerInset.top
        
        let characterIndex = layoutManager.characterIndexForPoint( location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil )
        
        if characterIndex < textView.textStorage.length
        {
            textViewTapDelegate?.textViewTapped?( characterIndex, cell: self )
        }
    }
}
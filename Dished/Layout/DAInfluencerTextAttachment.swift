//
//  DAInfluencerTextAttachment.swift
//  Dished
//
//  Created by Ryan Khalili on 4/16/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

class DAInfluencerTextAttachment: NSTextAttachment {
    
    let influencerImage = UIImage(named: "influencer")!
    
    override init() {
        super.init()
        image = influencerImage
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        image = influencerImage
    }
    
    override func attachmentBoundsForTextContainer(textContainer: NSTextContainer, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        var rect = CGRectZero
        rect.origin = CGPointMake(0, -3)
        rect.size = influencerImage.size
        return rect
    }
}
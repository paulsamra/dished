//
//  DAFoodieCollectionViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 3/27/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

protocol DAFoodieCollectionViewCellDelegate: class {
    func didTapImageAtIndex(index: Int, inFoodieCollectionViewCell cell: DAFoodieCollectionViewCell)
    func cellDidSwipeAway(cell: DAFoodieCollectionViewCell)
}

class DAFoodieCollectionViewCell: DACollectionViewCell, UIGestureRecognizerDelegate {
    
    var userImageView: UIImageView!
    var usernameButton: UIButton!
    var followButton: UIButton!
    var descriptionLabel: UILabel!
    var reviewImageViews: [UIImageView]!
    
    weak var delegate: DAFoodieCollectionViewCellDelegate?
    
    private var panGesture: UIPanGestureRecognizer!
    
    func configureWithFoodie(foodie: DAFoodie) {
        usernameButton.setTitle("@\(foodie.username)", forState: UIControlState.Normal)
        
        let nameAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0)]
        let nameString = NSMutableAttributedString(string: foodie.name, attributes: nameAttributes)
        
        if !foodie.description.isEmpty {
            let descriptionAttributes = [NSFontAttributeName: DAConstants.primaryFontWithSize(14.0)]
            let descriptionString = NSAttributedString(string: " - \(foodie.description)", attributes: descriptionAttributes)
            nameString.appendAttributedString(descriptionString)
        }
        
        descriptionLabel.attributedText = nameString
        
        let url = NSURL(string: foodie.image)
        let placeholder = UIImage(named: "profile_image")
        userImageView.sd_setImageWithURL(url, placeholderImage: placeholder)
        
        for (index, review) in enumerate(foodie.reviews) {
            if index < reviewImageViews.count {
                let url = NSURL(string: review.image)
                reviewImageViews[index].sd_setImageWithURL(url)
            }
        }
        
        if foodie.following {
            followButton.setTitle("Unfollow", forState: UIControlState.Normal)
            followButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        }
        else {
            followButton.setTitle("Follow", forState: UIControlState.Normal)
            followButton.setTitleColor(UIColor.followButtonColor(), forState: UIControlState.Normal)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        
        var x = (frame.size.width - (70.0 * 4) - (4.0 * 4)) / 2
        let y = userImageView.frame.origin.y + userImageView.frame.size.height + 12.0
        for imageView in reviewImageViews {
            imageView.frame = CGRectMake(x, y, 70.0, 70.0)
            addSubview(imageView)
            x += 74.0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.image = nil
        usernameButton.setTitle("", forState: UIControlState.Normal)
        descriptionLabel.text = ""
        
        for imageView in reviewImageViews {
            imageView.image = nil
        }
    }
    
    func didTapImageView(tapGesture: UITapGestureRecognizer) {
        let imageView = tapGesture.view as UIImageView
        if imageView.image != nil {
            if let index = find(reviewImageViews, imageView) {
                delegate?.didTapImageAtIndex(index, inFoodieCollectionViewCell: self)
            }
        }
    }
    
    func cellPanned(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Ended {
            if alpha <= 0.5 {
                delegate?.cellDidSwipeAway(self)
                return
            }
            
            var rect = frame
            rect.origin.x = 0.0
            
            UIView.animateWithDuration(0.2, animations: {
                self.frame = rect
                self.alpha = 1.0
            })
        }
        else if gesture.state == UIGestureRecognizerState.Changed {
            let translation = gesture.translationInView(self)
            
            if translation.x < 0 {
                var rect = frame
                rect.origin.x = translation.x
                frame = rect
                
                let percentage = -translation.x / frame.width
                alpha = 1 - percentage
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            let translation = panGesture.translationInView(panGesture.view!)
            return fabs(translation.y) <= fabs(translation.x)
        }
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let yVelocity = panGesture.velocityInView(self).y
            return fabs(yVelocity) <= 0.25
        }
        
        return true
    }
    
    override func setupViews() {
        backgroundColor = UIColor(r: 249, g: 249, b: 249, a: 255)
        
        userImageView = UIImageView()
        userImageView.contentMode = UIViewContentMode.ScaleAspectFill
        userImageView.clipsToBounds = true
        addSubview(userImageView)
        userImageView.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 10.0)
        userImageView.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 15.0)
        userImageView.autoSetDimensionsToSize(CGSizeMake(60.0, 60.0))
        
        followButton = UIButton()
        followButton.titleLabel?.font = DAConstants.primaryFontWithSize(18.0)
        followButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        addSubview(followButton)
        followButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 15.0)
        followButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 17.0)
        followButton.autoSetDimensionsToSize(CGSizeMake(68.0, 20.0))
        
        usernameButton = UIButton()
        usernameButton.titleLabel?.font = DAConstants.primaryFontWithSize(17.0)
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        usernameButton.setTitleColor(UIColor.dishedColor(), forState: UIControlState.Normal)
        addSubview(usernameButton)
        usernameButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 17.0)
        usernameButton.autoSetDimension(ALDimension.Height, toSize: 20.0)
        usernameButton.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Trailing, ofView: userImageView, withOffset: 8.0)
        usernameButton.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Leading, ofView: followButton, withOffset: 8.0)
        
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 2
        descriptionLabel.font = DAConstants.primaryFontWithSize(14.0)
        addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: usernameButton, withOffset: 4.0)
        descriptionLabel.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Trailing, ofView: userImageView, withOffset: 8.0)
        descriptionLabel.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: userImageView, withOffset: 2.0, relation: NSLayoutRelation.LessThanOrEqual)
        descriptionLabel.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Trailing, ofView: followButton)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(r: 174, g: 174, b: 174, a: 255)
        addSubview(separatorView)
        separatorView.autoSetDimension(ALDimension.Height, toSize: 0.5)
        separatorView.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        separatorView.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        separatorView.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        
        reviewImageViews = [UIImageView]()
        for i in 1...4 {
            let imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            imageView.userInteractionEnabled = true
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTapImageView:")
            tapRecognizer.numberOfTapsRequired = 1
            imageView.addGestureRecognizer(tapRecognizer)
            reviewImageViews.append(imageView)
        }
        
        panGesture = UIPanGestureRecognizer(target: self, action: "cellPanned:")
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
}
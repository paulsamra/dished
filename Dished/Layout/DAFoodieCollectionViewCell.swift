//
//  DAFoodieCollectionViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 3/27/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit

@objc protocol DAFoodieCollectionViewCellDelegate: class {
    func didTapImageAtIndex(index: Int, inFoodieCollectionViewCell cell: DAFoodieCollectionViewCell)
    func didDismissCell(cell: DAFoodieCollectionViewCell)
    func didTapUserImageViewInCell(cell: DAFoodieCollectionViewCell)
}

class DAFoodieCollectionViewCell: DACollectionViewCell, UIGestureRecognizerDelegate {
    
    var userImageView: UIImageView!
    var usernameButton: UIButton!
    var followButton: UIButton!
    var descriptionLabel: UILabel!
    var reviewImageViews: [UIImageView]!
    var dismissButton: UIButton!
    weak var delegate: DAFoodieCollectionViewCellDelegate?
    
    private var mainView: UIView!
    private let dismissButtonWidth = CGFloat(100.0)
    private var lastX: CGFloat = 0.0
    
    private var panGesture: UIPanGestureRecognizer!
    
    private func descriptionWithName(name: String, description: String, userType: String) -> NSAttributedString {
        let nameAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0)]
        let nameString = NSMutableAttributedString(string: name, attributes: nameAttributes)
        
        if userType == kInfluencerUserType {
            nameString.appendAttributedString(NSAttributedString(string: " "))
            let iconString = NSAttributedString(attachment: DAInfluencerTextAttachment())
            nameString.appendAttributedString(iconString)
        }
        
        if !description.isEmpty {
            let descriptionAttributes = [NSFontAttributeName: DAConstants.primaryFontWithSize(14.0)]
            let descriptionString = NSAttributedString(string: " - \(description)", attributes: descriptionAttributes)
            nameString.appendAttributedString(descriptionString)
        }
        
        return nameString
    }
    
    func configureWithFoodie(foodie: DAFoodie) {
        usernameButton.setTitle("@\(foodie.username)", forState: UIControlState.Normal)
        descriptionLabel.attributedText = descriptionWithName(foodie.name, description: foodie.description, userType: foodie.userType)
        
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
    
    func configureWithUserSuggestion(userSuggestion: DAManagedUserSuggestion) {
        usernameButton.setTitle("@\(userSuggestion.username)", forState: UIControlState.Normal)
        
        let name = "\(userSuggestion.first_name) \(userSuggestion.last_name)"
        descriptionLabel.attributedText = descriptionWithName(name, description: userSuggestion.desc, userType: userSuggestion.user_type)
        
        let placeholder = UIImage(named: "profile_image")
        
        if userSuggestion.img_thumb != nil {
            let url = NSURL(string: userSuggestion.img_thumb)
            userImageView.sd_setImageWithURL(url, placeholderImage: placeholder)
        }
        else {
            userImageView.image = placeholder
        }
        
        if let reviews = userSuggestion.reviews as? [NSDictionary] {
            for (index, review) in enumerate(reviews) {
                if index < reviewImageViews.count {
                    if let reviewImage = review.objectForKey(kImgThumbKey) as? String {
                        let url = NSURL(string: reviewImage)
                        reviewImageViews[index].sd_setImageWithURL(url)
                    }
                }
            }
        }

        if userSuggestion.following.boolValue == true {
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
        
        var x = (mainView.frame.size.width - (70.0 * 4) - (4.0 * 4)) / 2
        let y = userImageView.frame.origin.y + userImageView.frame.size.height + 12.0
        for imageView in reviewImageViews {
            imageView.frame = CGRectMake(x, y, 70.0, 70.0)
            mainView.addSubview(imageView)
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
        
        var rect = mainView.frame
        rect.origin.x = 0.0
        mainView.frame = rect
    }
    
    func didTapImageView(tapGesture: UITapGestureRecognizer) {
        let imageView = tapGesture.view as! UIImageView
        if imageView.image != nil {
            if let index = find(reviewImageViews, imageView) {
                delegate?.didTapImageAtIndex(index, inFoodieCollectionViewCell: self)
            }
        }
    }
    
    func dismissButtonPressed() {
        delegate?.didDismissCell(self)
    }
    
    func cellPanned(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Ended {
            var rect = mainView.frame
            var velocity = gesture.velocityInView(gesture.view)
            
            if velocity.x < 0.0 {
                rect.origin.x = -dismissButtonWidth
            }
            else {
                rect.origin.x = 0.0
            }
            
            UIView.animateWithDuration(0.2, animations: {
                self.mainView.frame = rect
            })
        }
        else if gesture.state == UIGestureRecognizerState.Changed {
            let translation = gesture.translationInView(self)
            
            if translation.x > 0.0 && mainView.frame.origin.x >= 0.0 {
                return
            }
            
            var rect = mainView.frame
            rect.origin.x = lastX + translation.x
            mainView.frame = rect
        }
        else if gesture.state == UIGestureRecognizerState.Began {
            lastX = mainView.frame.origin.x
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
    
    func didTapUserImageView() {
        delegate?.didTapUserImageViewInCell(self)
    }
    
    override func setupViews() {
        backgroundColor = UIColor(r: 249, g: 249, b: 249, a: 255)
        
        dismissButton = UIButton()
        let backgroundImage = UIImage.imageWithColor(UIColor.redColor())
        dismissButton.setBackgroundImage(backgroundImage, forState: UIControlState.Normal)
        dismissButton.setTitle("Dismiss", forState: UIControlState.Normal)
        dismissButton.titleLabel?.font = DAConstants.primaryFontWithSize(18.0)
        dismissButton.addTarget(self, action: "dismissButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(dismissButton)
        dismissButton.autoPinEdgeToSuperviewEdge(ALEdge.Top)
        dismissButton.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        dismissButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        dismissButton.autoSetDimension(ALDimension.Width, toSize: dismissButtonWidth)
        
        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = UIColor(r: 174, g: 174, b: 174, a: 255)
        contentView.addSubview(bottomSeparator)
        bottomSeparator.autoSetDimension(ALDimension.Height, toSize: 0.5)
        bottomSeparator.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        bottomSeparator.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        bottomSeparator.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
        
        let topSeparator = UIView()
        topSeparator.backgroundColor = UIColor(r: 174, g: 174, b: 174, a: 255)
        contentView.addSubview(topSeparator)
        topSeparator.autoSetDimension(ALDimension.Height, toSize: 0.5)
        topSeparator.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        topSeparator.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        topSeparator.autoPinEdgeToSuperviewEdge(ALEdge.Top)
        
        mainView = UIView()
        mainView.backgroundColor = backgroundColor
        contentView.addSubview(mainView)
        mainView.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
        mainView.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
        mainView.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: topSeparator)
        mainView.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Top, ofView: bottomSeparator)
        
        userImageView = UIImageView()
        userImageView.contentMode = UIViewContentMode.ScaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.userInteractionEnabled = true
        mainView.addSubview(userImageView)
        userImageView.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 10.0)
        userImageView.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 15.0)
        userImageView.autoSetDimensionsToSize(CGSizeMake(60.0, 60.0))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapUserImageView")
        tapGesture.numberOfTapsRequired = 1
        userImageView.addGestureRecognizer(tapGesture)
        
        followButton = UIButton()
        followButton.titleLabel?.font = DAConstants.primaryFontWithSize(18.0)
        followButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        mainView.addSubview(followButton)
        followButton.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 15.0)
        followButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 17.0)
        followButton.autoSetDimensionsToSize(CGSizeMake(68.0, 20.0))
        
        usernameButton = UIButton()
        usernameButton.titleLabel?.font = DAConstants.primaryFontWithSize(17.0)
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        usernameButton.setTitleColor(UIColor.dishedColor(), forState: UIControlState.Normal)
        mainView.addSubview(usernameButton)
        usernameButton.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 17.0)
        usernameButton.autoSetDimension(ALDimension.Height, toSize: 20.0)
        usernameButton.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Trailing, ofView: userImageView, withOffset: 8.0)
        usernameButton.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Leading, ofView: followButton, withOffset: 8.0)
        
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 2
        descriptionLabel.font = DAConstants.primaryFontWithSize(14.0)
        mainView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: usernameButton, withOffset: 4.0)
        descriptionLabel.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Trailing, ofView: userImageView, withOffset: 8.0)
        descriptionLabel.autoPinEdge(ALEdge.Bottom, toEdge: ALEdge.Bottom, ofView: userImageView, withOffset: 2.0, relation: NSLayoutRelation.LessThanOrEqual)
        descriptionLabel.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Trailing, ofView: followButton)
        
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
        mainView.addGestureRecognizer(panGesture)
    }
}
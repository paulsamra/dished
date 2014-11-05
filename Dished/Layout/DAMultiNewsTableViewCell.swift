//
//  DAMultiNewsTableViewCell.swift
//  Dished
//
//  Created by Ryan Khalili on 11/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit


@objc protocol DAMultiNewsTableViewCellDelegate
{
    optional func reviewImageTappedWithReviewID( reviewID: Int )
}


class DAMultiNewsTableViewCell: DANewsTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: DAMultiNewsTableViewCellDelegate?
    private var reviews: [Dictionary<String, String>] = []
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        imageCollectionView.registerClass( DAMultiNewsCollectionViewCell.self, forCellWithReuseIdentifier: "cell" )
    }
    
    func setReviewImages( images: [Dictionary<String, String>] )
    {
        reviews = images
        
        imageCollectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return reviews.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "cell", forIndexPath: indexPath ) as DAMultiNewsCollectionViewCell
        
        let review = reviews[indexPath.row]
        let urlString = review["img"]
        
        let url = NSURL( string: urlString! )
        cell.imageView.setImageWithURL( url, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray )
        
        return cell
    }
    
    func collectionView( collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath )
    {
        let review = reviews[indexPath.row]
        let reviewIDString = review["id"]
        let reviewID = reviewIDString?.toInt()
        
        delegate?.reviewImageTappedWithReviewID!( reviewID! )
    }
}

class DAMultiNewsCollectionViewCell: UICollectionViewCell
{
    var imageView: UIImageView!
    
    override init()
    {
        super.init()
        
        commonInit()
    }
    
    required init( coder aDecoder: NSCoder )
    {
        super.init( coder: aDecoder )
        
        commonInit()
    }
    
    func commonInit()
    {
        imageView = UIImageView( frame: self.contentView.frame )
        self.contentView.addSubview( imageView )
    }
}
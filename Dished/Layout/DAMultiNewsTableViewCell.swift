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
    optional func reviewImageTappedAtIndex( index: Int, inCell cell: DAMultiNewsTableViewCell )
}


class DAMultiNewsTableViewCell: DANewsTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: DAMultiNewsTableViewCellDelegate?
    private var reviews: [String] = []
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        imageCollectionView.registerClass( DAMultiNewsCollectionViewCell.self, forCellWithReuseIdentifier: "cell" )
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        reviews = [];
        
        imageCollectionView.reloadData()
        imageCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setReviewImages( images: [String] )
    {
        reviews = images
        
        imageCollectionView.reloadData()
        imageCollectionView.collectionViewLayout.invalidateLayout()
        
        collectionViewHeightConstraint.constant = imageCollectionView.collectionViewLayout.collectionViewContentSize().height
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
        
        let imageURL = reviews[indexPath.row]
        
        let url = NSURL( string: imageURL )
        cell.imageView.sd_setImageWithURL( url );
        
        return cell
    }
    
    func collectionView( collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath )
    {
        delegate?.reviewImageTappedAtIndex!( indexPath.row, inCell: self )
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
    
    override init( frame: CGRect )
    {
        super.init( frame: frame )
        
        commonInit();
    }
    
    required init( coder aDecoder: NSCoder )
    {
        super.init( coder: aDecoder )
        
        commonInit()
    }
    
    func commonInit()
    {
        imageView = UIImageView( frame: self.contentView.frame )
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.layer.masksToBounds = true
        self.contentView.addSubview( imageView )
    }
}
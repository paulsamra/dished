//
//  DAFlowLayout.swift
//  Dished
//
//  Created by Ryan Khalili on 12/21/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

import UIKit

class DAFlowLayout: UICollectionViewFlowLayout
{
    weak var navigationBar: UINavigationBar?
    weak var refreshControl: DARefreshControl?
    
    override func layoutAttributesForElementsInRect( rect: CGRect ) -> [AnyObject]?
    {
        var answer = super.layoutAttributesForElementsInRect( rect ) as! [UICollectionViewLayoutAttributes]
        let collectionView = self.collectionView
        let contentOffset = collectionView?.contentOffset
        
        var missingSections = NSMutableIndexSet()
        
        for layoutAttributes in answer
        {
            if layoutAttributes.representedElementCategory == UICollectionElementCategory.Cell
            {
                missingSections.addIndex( layoutAttributes.indexPath.section )
            }
        }
        
        for layoutAttributes in answer
        {
            if layoutAttributes.representedElementKind != nil
            {
                if layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader
                {
                    missingSections.addIndex( layoutAttributes.indexPath.section )
                }
            }
        }
        
        missingSections.enumerateIndexesUsingBlock { ( index, stop ) -> Void in
            
            let indexPath = NSIndexPath( forItem: 0, inSection: index )
            
            let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind( UICollectionElementKindSectionHeader, atIndexPath: indexPath )
            
            answer.append( layoutAttributes )
        }
        
        for layoutAttributes in answer
        {
            if layoutAttributes.representedElementKind != nil
            {
                if layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader
                {
                    let section = layoutAttributes.indexPath.section
                    let items = collectionView?.numberOfItemsInSection( section )
                    
                    let firstIndexPath = NSIndexPath( forItem: 0, inSection: section )
                    let lastIndexPath = NSIndexPath( forItem: max( 0, items! - 1 ), inSection: section )
                    
                    var cellsExist: Bool
                    var firstObjectAttributes: UICollectionViewLayoutAttributes
                    var lastObjectAttributes: UICollectionViewLayoutAttributes
                    
                    if items > 0
                    {
                        cellsExist = true
                        firstObjectAttributes = self.layoutAttributesForItemAtIndexPath( firstIndexPath )
                        lastObjectAttributes = self.layoutAttributesForItemAtIndexPath( lastIndexPath )
                    }
                    else
                    {
                        cellsExist = false
                        firstObjectAttributes = self.layoutAttributesForSupplementaryViewOfKind( UICollectionElementKindSectionHeader, atIndexPath: firstIndexPath )
                        lastObjectAttributes = self.layoutAttributesForSupplementaryViewOfKind( UICollectionElementKindSectionFooter, atIndexPath: lastIndexPath )
                    }
                    
                    let topHeaderHeight = cellsExist ? CGRectGetHeight( layoutAttributes.frame ) : 0
                    let bottomHeaderHeight = CGRectGetHeight( layoutAttributes.frame )
                    let contentInset = collectionView?.contentInset
                    let frameWithEdgeInsets = UIEdgeInsetsInsetRect( layoutAttributes.frame, contentInset! )
                    var origin = frameWithEdgeInsets.origin
                    
                    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
                    var navigationBarOffset = CGFloat( 0.0 )
                    var refreshControlOffset = CGFloat( 0.0 )
                    var refreshControlHiddenOffset = CGFloat( 0.0 )
                    
                    if navigationBar != nil
                    {
                        let navigationBarFrame = navigationBar!.frame
                        navigationBarOffset = navigationBarFrame.origin.y + navigationBarFrame.size.height
                    }
                    
                    if refreshControl != nil
                    {
                        if !refreshControl!.isRefreshing()
                        {
                            let refreshControlFrame = refreshControl!.frame
                            refreshControlOffset = refreshControlFrame.size.height
                            
                            if contentOffset?.y > ( statusBarHeight * -1 )
                            {
                                refreshControlHiddenOffset = statusBarHeight * 2
                            }
                        }
                    }
                    
                    origin.y = min( max( contentOffset!.y + navigationBarOffset - refreshControlOffset + refreshControlHiddenOffset,
                                    ( CGRectGetMinY( firstObjectAttributes.frame ) - topHeaderHeight ) ),
                                    ( CGRectGetMaxY( lastObjectAttributes.frame ) - bottomHeaderHeight ) )
                    
                    layoutAttributes.zIndex = 100
                    
                    layoutAttributes.frame = CGRect( origin: origin, size: layoutAttributes.frame.size )
                }
                else
                {
                    layoutAttributes.zIndex = 1
                    layoutAttributes.transform3D = CATransform3DMakeTranslation( 0, 0, -2 )
                }
            }
        }
        
        return answer
    }
    
    override func shouldInvalidateLayoutForBoundsChange( newBounds: CGRect ) -> Bool
    {
        return true
    }
}
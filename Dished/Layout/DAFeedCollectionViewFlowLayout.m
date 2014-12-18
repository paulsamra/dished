//
//  DACollectionViewFlowLayout.m
//  Dished
//
//  Created by Ryan Khalili on 9/13/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedCollectionViewFlowLayout.h"


@implementation DAFeedCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    UICollectionView * const cv = self.collectionView;
    CGPoint const contentOffset = cv.contentOffset;
    
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    
    for( UICollectionViewLayoutAttributes *layoutAttributes in answer )
    {
        if( layoutAttributes.representedElementCategory == UICollectionElementCategoryCell )
        {
            [missingSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    
    for( UICollectionViewLayoutAttributes *layoutAttributes in answer )
    {
        if( [layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] )
        {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }
    
    [missingSections enumerateIndexesUsingBlock:^( NSUInteger idx, BOOL *stop )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        
        [answer addObject:layoutAttributes];
    }];
    
    for( UICollectionViewLayoutAttributes *layoutAttributes in answer )
    {
        if( [layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] )
        {
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
            
            NSIndexPath *firstObjectIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:MAX( 0, ( numberOfItemsInSection - 1 ) ) inSection:section];
            
            BOOL cellsExist;
            UICollectionViewLayoutAttributes *firstObjectAttrs;
            UICollectionViewLayoutAttributes *lastObjectAttrs;
            
            if (numberOfItemsInSection > 0)
            {
                cellsExist = YES;
                firstObjectAttrs = [self layoutAttributesForItemAtIndexPath:firstObjectIndexPath];
                lastObjectAttrs = [self layoutAttributesForItemAtIndexPath:lastObjectIndexPath];
            }
            else
            {
                cellsExist = NO;
                firstObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                        atIndexPath:firstObjectIndexPath];
                lastObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                       atIndexPath:lastObjectIndexPath];
            }
            
            CGFloat topHeaderHeight = cellsExist ? CGRectGetHeight( layoutAttributes.frame ) : 0;
            CGFloat bottomHeaderHeight = CGRectGetHeight( layoutAttributes.frame );
            CGRect frameWithEdgeInsets = UIEdgeInsetsInsetRect( layoutAttributes.frame, cv.contentInset );
            
            CGPoint origin = frameWithEdgeInsets.origin;
            
            CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
            CGFloat navigationBarOffset  = 0;
            CGFloat refreshControlOffset = 0;
            CGFloat refreshControlHiddenOffset = 0;
            
            if( self.navigationBar )
            {
                CGRect navigationBarFrame = self.navigationBar.frame;
                navigationBarOffset = navigationBarFrame.origin.y + navigationBarFrame.size.height;
            }
            
            if( self.refreshControl && [self.refreshControl isRefreshing] )
            {
                CGRect refreshControlFrame = self.refreshControl.frame;
                refreshControlOffset = refreshControlFrame.size.height;
                
                if( contentOffset.y > -[[UIApplication sharedApplication] statusBarFrame].size.height )
                {
                    refreshControlHiddenOffset = statusBarHeight * 2;
                }
            }
            
            origin.y = MIN( MAX( contentOffset.y + navigationBarOffset - refreshControlOffset + refreshControlHiddenOffset,
                               ( CGRectGetMinY(firstObjectAttrs.frame) - topHeaderHeight) ),
                               ( CGRectGetMaxY(lastObjectAttrs.frame) - bottomHeaderHeight ) );
                        
            layoutAttributes.zIndex = 100;
            
            layoutAttributes.frame = (CGRect)
            {
                .origin = origin,
                .size = layoutAttributes.frame.size
            };
        }
    }
    
    return answer;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    return YES;
}

@end
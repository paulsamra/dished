//
//  DAImageFilterViewController.m
//  Dished
//
//  Created by Ryan Khalili on 7/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAImageFilterViewController.h"


@interface DAImageFilterViewController()

@property (strong, nonatomic) NSArray        *filterTitles;
@property (strong, nonatomic) NSArray        *filterNames;
@property (strong, nonatomic) NSMutableArray *filteredImages;

@property (nonatomic) int selectedIndex;

@end


@implementation DAImageFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pictureImageView.image = self.pictureTaken;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.filterTitles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    [imageView.layer setMasksToBounds:YES];
    imageView.layer.cornerRadius = 10;
    
    if( self.selectedIndex == indexPath.row )
    {
        imageView.layer.borderColor = [[UIColor orangeColor] CGColor];
        imageView.layer.borderWidth = 2;
    }
    else
    {
        imageView.layer.borderWidth = 0;
    }
    
    if( ![self.filteredImages[indexPath.row] isEqual:[NSNull null]] )
    {
        imageView.image = self.filteredImages[indexPath.row];
    }
    else
    {
        if( indexPath.row == 0 )
        {
            self.filteredImages[indexPath.row] = self.pictureTaken;
            imageView.image = self.pictureTaken;
        }
        else
        {
            CIImage *beginImage = [CIImage imageWithCGImage:[self.pictureTaken CGImage]];
            CIContext *context = [CIContext contextWithOptions:nil];
            
            CIFilter *filter = [CIFilter filterWithName:self.filterNames[indexPath.row] keysAndValues: kCIInputImageKey, beginImage, nil];
            CIImage *outputImage = [filter outputImage];
            
            CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
            UIImage *newImg = [UIImage imageWithCGImage:cgimg];
            
            self.filteredImages[indexPath.row] = newImg;
            [imageView setImage:newImg];
            
            CGImageRelease(cgimg);
        }
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:200];
    label.text = [self.filterTitles objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = (int)indexPath.row;
    
    self.pictureImageView.image = self.filteredImages[indexPath.row];
    
    [self.collectionView reloadData];
}

- (NSArray *)filterTitles
{
    if( !_filterTitles )
    {
        _filterTitles = @[ @"No Filter", @"Sepia", @"Sepia", @"Sepia" ];
    }
    
    return _filterTitles;
}

- (NSArray *)filterNames
{
    if( !_filterNames )
    {
        _filterNames = @[ @"None", @"CISepiaTone", @"CISepiaTone", @"CISepiaTone" ];
    }
    
    return _filterNames;
}

- (NSArray *)filteredImages
{
    if( !_filteredImages )
    {
        _filteredImages = [NSMutableArray array];
        
        for( int i = 0; i < [self.filterNames count]; i++ )
        {
            _filteredImages[i] = [NSNull null];
        }
    }
    
    return _filteredImages;
}

@end
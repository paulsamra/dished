//
//  DAImageFilterViewController.m
//  Dished
//
//  Created by Ryan Khalili on 7/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAImageFilterViewController.h"
#import "DAImagePickerController.h"
#import "DAReviewFormViewController.h"
#import "DANewReview.h"


@interface DAImageFilterViewController()

@property (strong, nonatomic) DANewReview             *review;
@property (strong, nonatomic) NSArray                 *filterTitles;
@property (strong, nonatomic) NSArray                 *filterNames;
@property (strong, nonatomic) NSArray                 *filterImages;
@property (strong, nonatomic) NSMutableDictionary     *filteredImages;

@property (nonatomic) int selectedIndex;

@end


@implementation DAImageFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedIndex = 0;
    self.filteredImages = [NSMutableDictionary dictionary];
    self.pictureImageView.backgroundColor = [UIColor blackColor];
    
    DAImagePickerController *parentVC = [self.navigationController.viewControllers objectAtIndex:0];
    
    self.review = [[DANewReview alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady:) name:kImageReadyNotificationKey object:nil];
    
    if( parentVC.pictureTaken )
    {
        UIImage *pictureTaken = parentVC.pictureTaken;
        
        self.pictureTaken = pictureTaken;
        self.pictureImageView.image = self.pictureTaken;
        
        self.filteredImages[self.filterNames[0]] = self.pictureTaken;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.spinner startAnimating];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)imageReady:(NSNotification *)notification;
{
    UIImage *pictureTaken = notification.object;
    
    self.pictureTaken = pictureTaken;
    
    self.filteredImages[self.filterNames[0]] = self.pictureTaken;
    [self filterImageAtIndex:self.selectedIndex];
    
    self.pictureImageView.image = self.filteredImages[self.filterNames[self.selectedIndex]];

    [self.spinner stopAnimating];
    
    [self.collectionView reloadData];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
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
    imageView.layer.cornerRadius = 6;
    
    if( self.selectedIndex == indexPath.row )
    {
        imageView.layer.borderColor = [[UIColor orangeColor] CGColor];
        imageView.layer.borderWidth = 2;
    }
    else
    {
        imageView.layer.borderWidth = 0;
    }
    
    imageView.image = [UIImage imageNamed:self.filterImages[indexPath.row]];
    UILabel *label = (UILabel *)[cell viewWithTag:200];
    label.text = [self.filterTitles objectAtIndex:indexPath.row];
    
    return cell;
}

- (UIImage *)filterImage:(UIImage *)image withFilterName:(NSString *)filterName
{
    CIImage *beginImage = [CIImage imageWithCGImage:[image CGImage]];
    
    CIFilter *filter = filter = [CIFilter filterWithName:filterName];
    [filter setValue:beginImage forKeyPath:kCIInputImageKey];
    
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:outputImage fromRect:outputImage.extent];
    UIImage *newImg = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return newImg;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = (int)indexPath.row;
    
    [self filterImageAtIndex:indexPath.row];
    
    self.pictureImageView.image = self.filteredImages[self.filterNames[indexPath.row]];
    [self.collectionView reloadData];
}

- (void)filterImageAtIndex:(NSInteger)index
{
    UIImage *filteredImage = self.filteredImages[self.filterNames[index]];
    
    if( !filteredImage )
    {
        if( index != 0 )
        {
            NSString *filterName = self.filterNames[index];
            
            UIImage *newImage = [self filterImage:self.pictureTaken withFilterName:filterName];
            
            if( newImage )
            {
                self.filteredImages[self.filterNames[index]] = newImage;
            }
        }
    }
}

- (IBAction)goToDetails:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"form" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"form"] )
    {
        DAReviewFormViewController *dest = [segue destinationViewController];
        dest.reviewImage = self.filteredImages[self.filterNames[self.selectedIndex]];
        dest.review = self.review;        
    }
}

- (NSArray *)filterImages
{
    if( !_filterImages )
    {
        NSMutableArray *imageNames = [NSMutableArray array];
        
        for( NSString *title in self.filterTitles )
        {
            if( [self.filterTitles indexOfObject:title] == 0 )
            {
                [imageNames addObject:@"no_filter"];
            }
            else
            {
                [imageNames addObject:[NSString stringWithFormat:@"%@_filter", [title lowercaseString]]];
            }
        }
        
        _filterImages = imageNames;
    }
    
    return _filterImages;
}

- (NSArray *)filterTitles
{
    if( !_filterTitles )
    {
        _filterTitles = @[ @"No Filter", @"Garlic", @"Ginger", @"Coriander", @"Cumin", @"Salt", @"Pepper", @"Thyme", @"Paprika" ];
    }
    
    return _filterTitles;
}

- (NSArray *)filterNames
{
    if( !_filterNames )
    {
        _filterNames = @[ @"None", @"CIPhotoEffectInstant", @"CIPhotoEffectTransfer", @"CIPhotoEffectProcess", @"CISepiaTone", @"CIPhotoEffectNoir", @"CIPhotoEffectTonal", @"CIPhotoEffectChrome", @"CIFalseColor" ];
    }
    
    return _filterNames;
}

@end
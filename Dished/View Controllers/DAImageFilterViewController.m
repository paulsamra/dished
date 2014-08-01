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

@property (strong, nonatomic) DANewReview           *foodReview;
@property (strong, nonatomic) DANewReview           *cocktailReview;
@property (strong, nonatomic) DANewReview           *wineReview;
@property (strong, nonatomic) NSArray               *filterTitles;
@property (strong, nonatomic) NSArray               *filterNames;
@property (strong, nonatomic) NSMutableDictionary   *filteredImages;
@property (strong, nonatomic) NSOperationQueue      *imageFilterQueue;

@property (nonatomic) int selectedIndex;

@end


@implementation DAImageFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pictureImageView.backgroundColor = [UIColor blackColor];
    
    DAImagePickerController *parentVC = [self.navigationController.viewControllers objectAtIndex:0];
    
    if( parentVC.pictureTaken )
    {
        UIImage *pictureTaken = parentVC.pictureTaken;
        
        self.pictureTaken = pictureTaken;
        self.pictureImageView.image = self.pictureTaken;
    }
    
    self.foodReview     = [[DANewReview alloc] init];
    self.cocktailReview = [[DANewReview alloc] init];
    self.wineReview     = [[DANewReview alloc] init];
    
    self.foodReview.type     = kFood;
    self.cocktailReview.type = kCocktail;
    self.wineReview.type     = kWine;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady:) name:kImageReadyNotificationKey object:nil];
    
    self.imageFilterQueue = [[NSOperationQueue alloc] init];
    self.imageFilterQueue.maxConcurrentOperationCount = 1;
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
    self.pictureImageView.image = self.pictureTaken;
    
    [self.collectionView reloadData];
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
    
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:101];
    
    if( self.filteredImages[self.filterNames[indexPath.row]] )
    {
        imageView.image = self.filteredImages[self.filterNames[indexPath.row]];
    }
    else
    {
        if( indexPath.row == 0 )
        {
            if( !self.pictureTaken )
            {
                [spinner startAnimating];
            }
            else
            {
                self.filteredImages[self.filterNames[indexPath.row]] = self.pictureTaken;
                imageView.image = self.pictureTaken;
                
                [spinner stopAnimating];
            }
        }
        else
        {
            [spinner startAnimating];
            
            if( self.pictureTaken )
            {
                NSBlockOperation *filterOperation = [NSBlockOperation blockOperationWithBlock:^
                {
                    CIImage *beginImage = [CIImage imageWithCGImage:[self.pictureTaken CGImage]];
                    
                    CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
                    [scaleFilter setValue:beginImage forKeyPath:@"inputImage"];
                    [scaleFilter setValue:@(0.4f) forKeyPath:@"inputScale"];
                    [scaleFilter setValue:@(1.0f) forKeyPath:@"inputAspectRatio"];
                    
                    CIFilter *filter = [CIFilter filterWithName:self.filterNames[indexPath.row]];
                    [filter setValue:scaleFilter.outputImage forKeyPath:kCIInputImageKey];
                    
                    CIImage *outputImage = [filter outputImage];
                    
                    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:outputImage fromRect:outputImage.extent];
                    UIImage *newImg = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    dispatch_async( dispatch_get_main_queue(), ^
                    {
                        self.filteredImages[self.filterNames[indexPath.row]] = newImg;
                        [imageView setImage:newImg];
                       
                        [spinner stopAnimating];
                    });
                }];
                
                [self.imageFilterQueue addOperation:filterOperation];
            }
        }
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:200];
    label.text = [self.filterTitles objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = (int)indexPath.row;
    
    self.pictureImageView.image = self.filteredImages[self.filterNames[indexPath.row]];
    
    [self.collectionView reloadData];
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
        dest.reviewImage = self.pictureImageView.image;
        
        dest.foodReview     = self.foodReview;
        dest.wineReview     = self.wineReview;
        dest.cocktailReview = self.cocktailReview;
    }
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

- (NSMutableDictionary *)filteredImages
{
    if( !_filteredImages )
    {
        _filteredImages = [NSMutableDictionary dictionary];
    }
    
    return _filteredImages;
}

@end
//
//  DAImageFilterViewController.m
//  Dished
//
//  Created by Ryan Khalili on 7/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAImageFilterViewController.h"
#import "DAImagePickerController.h"
#import "DAFormTableViewController.h"

@interface DAImageFilterViewController()

@property (strong, nonatomic) UIImage               *scaledImage;
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
        
        CGSize newSize = CGSizeMake( pictureTaken.size.width / 4, pictureTaken.size.height / 4 );
        UIGraphicsBeginImageContextWithOptions( newSize, NO, 0.0 );
        [pictureTaken drawInRect:CGRectMake( 0, 0, newSize.width, newSize.height )];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.scaledImage = newImage;
        self.pictureTaken = pictureTaken;
        self.pictureImageView.image = self.scaledImage;
    }
    
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
    
    CGSize newSize = CGSizeMake( pictureTaken.size.width / 4, pictureTaken.size.height / 4 );
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 0.0 );
    [pictureTaken drawInRect:CGRectMake( 0, 0, newSize.width, newSize.height )];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"%f, %f", newImage.size.width, newImage.size.height);
    self.scaledImage = newImage;
    self.pictureTaken = pictureTaken;
    self.pictureImageView.image = self.scaledImage;
    
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
            if( !self.scaledImage )
            {
                [spinner startAnimating];
            }
            else
            {
                self.filteredImages[self.filterNames[indexPath.row]] = self.scaledImage;
                imageView.image = self.scaledImage;
                
                [spinner stopAnimating];
            }
        }
        else
        {
            [spinner startAnimating];
            
            if( self.scaledImage )
            {
                NSBlockOperation *filterOperation = [NSBlockOperation blockOperationWithBlock:^
                {
                    CIImage *beginImage = [CIImage imageWithCGImage:[self.scaledImage CGImage]];
                    
                    CIFilter *filter = [CIFilter filterWithName:self.filterNames[indexPath.row] keysAndValues:kCIInputImageKey, beginImage, nil];
                    CIImage *outputImage = [filter outputImage];
                    
                    UIImage *newImg = [UIImage imageWithCIImage:outputImage];
                    
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
    [self performSegueWithIdentifier:@"goToDetails" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"form"] )
    {
        DAFormTableViewController *dest = [segue destinationViewController];
        dest.reviewImage = self.pictureImageView.image;
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
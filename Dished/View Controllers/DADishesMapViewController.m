//
//  DADishesMapViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/25/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADishesMapViewController.h"
#import "DAMapAnnotation.h"
#import "DAAnnotationView.h"
#import "UIImageView+WebCache.h"
#import "DAReviewDetailsViewController.h"


@interface DADishesMapViewController()

@property (strong, nonatomic) NSArray *annotations;

@end


@implementation DADishesMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    self.navigationItem.title = @"Dish Map";
    
    NSMutableDictionary *annotations = [NSMutableDictionary dictionary];
    
    for( DAReview *review in self.dishes )
    {
        DAMapAnnotation *locationAnnotation = [annotations objectForKey:@(review.loc_id)];

        if( locationAnnotation )
        {
            [locationAnnotation.dishes addObject:review];
        }
        else
        {
            CLLocationCoordinate2D coordinate = { review.latitude, review.longitude };
            DAMapAnnotation *annotation = [[DAMapAnnotation alloc] init];
            annotation.coordinate = coordinate;
            annotation.img_thumb = review.img_thumb;
            
            if( !annotation.dishes )
            {
                annotation.dishes = [NSMutableArray array];
            }
            
            [annotation.dishes addObject:review];
            
            [annotations setObject:annotation forKey:@(review.loc_id)];
        }
    }
    
    for( DAMapAnnotation *locationAnnotation in [annotations allValues] )
    {
        [self.mapView addAnnotation:locationAnnotation];
    }
    
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    DAMapAnnotation *dishAnnotation = (DAMapAnnotation *)annotation;
    
    static NSString *viewIdentifier = @"dishMapAnnotationViewIdentifier";
    
    DAAnnotationView *annotationView = [[DAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:viewIdentifier dishNumber:dishAnnotation.dishes.count];
    
    NSURL *url = [NSURL URLWithString:dishAnnotation.img_thumb];
    [annotationView.dishImageView sd_setImageWithURL:url];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    DAMapAnnotation *annotation = view.annotation;
    
    if( annotation.dishes.count == 1 )
    {
        DAReview *review = [annotation.dishes objectAtIndex:0];
        
        DAReviewDetailsViewController *reviewDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"reviewDetails"];
        reviewDetailsViewController.reviewID = review.review_id;
        [self.navigationController pushViewController:reviewDetailsViewController animated:YES];
    }
}

@end
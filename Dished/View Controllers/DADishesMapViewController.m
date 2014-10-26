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
    
    for( DADish *dish in self.dishes )
    {
        DAMapAnnotation *locationAnnotation = [annotations objectForKey:@(dish.locationID)];

        if( locationAnnotation )
        {
            [locationAnnotation.dishes addObject:dish];
        }
        else
        {
            CLLocationCoordinate2D coordinate = { dish.latitude, dish.longitude };
            DAMapAnnotation *annotation = [[DAMapAnnotation alloc] init];
            annotation.coordinate = coordinate;
            annotation.img_thumb = dish.imageURL;
            
            if( !annotation.dishes )
            {
                annotation.dishes = [NSMutableArray array];
            }
            
            [annotation.dishes addObject:dish];
            
            [annotations setObject:annotation forKey:@(dish.locationID)];
        }
    }
    
    for( DAMapAnnotation *locationAnnotation in [annotations allValues] )
    {
        [self.mapView addAnnotation:locationAnnotation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
}

@end
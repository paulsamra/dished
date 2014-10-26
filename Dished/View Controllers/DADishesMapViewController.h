//
//  DADishesMapViewController.h
//  Dished
//
//  Created by Ryan Khalili on 10/25/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DADish.h"


@interface DADishesMapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) NSArray *dishes;

@end
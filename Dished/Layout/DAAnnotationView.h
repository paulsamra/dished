//
//  DAAnnotationView.h
//  Dished
//
//  Created by Ryan Khalili on 10/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface DAAnnotationView : MKAnnotationView

@property (strong, nonatomic) UILabel     *dishNumberLabel;
@property (strong, nonatomic) UIImageView *dishImageView;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier dishNumber:(NSInteger)dishNumber;

@end
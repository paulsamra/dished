//
//  DAAnnotationView.m
//  Dished
//
//  Created by Ryan Khalili on 10/26/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAAnnotationView.h"


@implementation DAAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier dishNumber:(NSInteger)dishNumber
{
    if( self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] )
    {
        _dishImageView = [[UIImageView alloc] init];
        _dishImageView.contentMode = UIViewContentModeScaleAspectFill;
        _dishImageView.layer.masksToBounds = YES;
        [self addSubview:_dishImageView];
        
        if( dishNumber > 1 )
        {
            _dishNumberLabel = [[UILabel alloc] init];
            UIImage *badgeImage = [UIImage imageNamed:@"map_badge"];
            _dishNumberLabel.backgroundColor = [UIColor colorWithPatternImage:badgeImage];
            _dishNumberLabel.text = [NSString stringWithFormat:@"%d", (int)dishNumber];
            _dishNumberLabel.textColor = [UIColor whiteColor];
            _dishNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
            _dishNumberLabel.textAlignment = NSTextAlignmentCenter;
            _dishNumberLabel.adjustsFontSizeToFitWidth = YES;

            
            self.image = [UIImage imageNamed:@"multi_dish_map"];
            
            _dishImageView.frame = CGRectMake( 8, 9, 45, 32 );
            
            _dishNumberLabel.frame = CGRectMake( 35, -5, badgeImage.size.width, badgeImage.size.height );
            
            [self addSubview:_dishNumberLabel];
        }
        else
        {
            self.image = [UIImage imageNamed:@"single_dish_map"];
            
            _dishImageView.frame = CGRectMake( 7, 6, 44, 32 );
        }
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.dishImageView.image = nil;
    self.dishNumberLabel.text = nil;
}

@end
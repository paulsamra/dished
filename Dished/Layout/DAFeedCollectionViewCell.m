//
//  DAFeedCollectionViewCell.m
//  Dished
//
//  Created by Ryan Khalili on 8/20/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedCollectionViewCell.h"


@implementation DAFeedCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.clipsToBounds = YES;
    
    self.titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.commentsButton addTarget:self action:@selector(commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.titleButton    addTarget:self action:@selector(titleButtonTapped)   forControlEvents:UIControlEventTouchUpInside];
    [self.yumButton      addTarget:self action:@selector(yumButtonTapped)     forControlEvents:UIControlEventTouchUpInside];
    
    self.commentsButton.layer.cornerRadius = 5;
    self.yumButton.layer.cornerRadius = 5;
    self.commentsButton.layer.masksToBounds = YES;
    self.yumButton.layer.masksToBounds = YES;
    
    self.dishImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dishImageDoubleTapped)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.dishImageView addGestureRecognizer:doubleTapGesture];
}

- (void)dishImageDoubleTapped
{
    if( [self.delegate respondsToSelector:@selector(imageDoubleTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate imageDoubleTappedOnFeedCollectionViewCell:self];
    }
}

- (void)commentButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(commentButtonTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate commentButtonTappedOnFeedCollectionViewCell:self];
    }
}

- (void)titleButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(titleButtonTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate titleButtonTappedOnFeedCollectionViewCell:self];
    }
}

- (void)yumButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(yumButtonTappedOnFeedCollectionViewCell:)] )
    {
        [self.delegate yumButtonTappedOnFeedCollectionViewCell:self];
    }
}

+ (NSAttributedString *)attributedTimeStringWithDate:(NSDate *)date
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:date];
    
    NSString *format = nil;
    NSInteger value  = 0;
    
    if( timeInterval < 60 )
    {
        format = @"%lds";
        value = timeInterval;
    }
    else if( timeInterval < 3600 )
    {
        format = @"%ldm";
        value = timeInterval / 60;
    }
    else if( timeInterval < 86400 )
    {
        value = timeInterval / 3600;
        format = @"%ldh";
    }
    else
    {
        NSInteger start = [currentCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
        NSInteger end = [currentCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:currentDate];
        
        if( timeInterval < 604800 )
        {
            value = end - start;
            format = @"%ldd";
        }
        else
        {
            value = ( end - start ) / 7;
            format = @"%ldw";
        }
    }
    
    NSString *timeString = [NSString stringWithFormat:format, value];
    
    NSMutableAttributedString *attributedTimeString = [[NSMutableAttributedString alloc] initWithString:timeString];
    
    [attributedTimeString insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
    
    NSTextAttachment *clockAttachment = [[NSTextAttachment alloc] init];
    clockAttachment.image = [UIImage imageNamed:@"clock"];
    NSMutableAttributedString *clockString = [[NSAttributedString attributedStringWithAttachment:clockAttachment] mutableCopy];
    
    [clockString appendAttributedString:attributedTimeString];
    
    return clockString;
}

@end
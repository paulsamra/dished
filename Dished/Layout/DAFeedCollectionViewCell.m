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
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    unsigned int unitFlags = NSSecondCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit;
    
    NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:date  toDate:[NSDate date]  options:0];
    
    NSString *format = nil;
    NSInteger value  = 0;
    
    if( timeInterval < 60 )
    {
        format = @"%lds";
        value = conversionInfo.second;
    }
    else if( timeInterval < 3600 )
    {
        format = @"%ldm";
        value = conversionInfo.minute;
    }
    else if( timeInterval < 86400 )
    {
        format = @"%ldh";
        value = conversionInfo.hour;
    }
    else if( timeInterval < 604800 )
    {
        format = @"%ldd";
        value = conversionInfo.day;
    }
    else
    {
        format = @"%ldw";
        value = conversionInfo.weekOfYear;
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
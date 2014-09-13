//
//  DAGlobalReviewCollectionViewCell.m
//  Dished
//
//  Created by Ryan Khalili on 9/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGlobalReviewCollectionViewCell.h"


@implementation DAGlobalReviewCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.gradeView.layer.cornerRadius = self.gradeView.frame.size.width / 2;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;
    
    self.commentTextView.textContainerInset = UIEdgeInsetsZero;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = bounds;
}

+ (NSDictionary *)commentTextAttributes
{
    return @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:15] };
}

+ (NSAttributedString *)attributedTimeStringWithDate:(NSDate *)date
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if( timeInterval < 86400 )
    {
        dateFormatter.dateFormat = @"hh:mm a";
    }
    else
    {
        dateFormatter.dateFormat = @"d MMM";
    }
    
    NSString *timeString = [[dateFormatter stringFromDate:date] uppercaseString];
    
    NSMutableAttributedString *attributedTimeString = [[NSMutableAttributedString alloc] initWithString:timeString];
    
    [attributedTimeString insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
    
    NSTextAttachment *clockAttachment = [[NSTextAttachment alloc] init];
    clockAttachment.image = [UIImage imageNamed:@"clock"];
    NSMutableAttributedString *clockString = [[NSAttributedString attributedStringWithAttachment:clockAttachment] mutableCopy];
    
    [clockString appendAttributedString:attributedTimeString];
    
    return clockString;
}

@end
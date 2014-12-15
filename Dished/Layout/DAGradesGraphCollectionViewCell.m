//
//  DAGradesGraphCollectionViewCell.m
//  Dished
//
//  Created by Ryan Khalili on 12/14/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGradesGraphCollectionViewCell.h"


@interface DAGradesGraphCollectionViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradeAWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradeBWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradeCWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gradeDWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *verticalAxis;
@property (weak, nonatomic) IBOutlet UIView *horizontalAxis;

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) NSInteger aGrades;
@property (nonatomic) NSInteger bGrades;
@property (nonatomic) NSInteger cGrades;
@property (nonatomic) NSInteger dfGrades;

@end


@implementation DAGradesGraphCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.gradeABarButton  addTarget:self action:@selector(gradeBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.gradeBBarButton  addTarget:self action:@selector(gradeBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.gradeCBarButton  addTarget:self action:@selector(gradeBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.gradeDFBarButton addTarget:self action:@selector(gradeBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.moreButton addTarget:self action:@selector(moreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.gradeGraphMode = eGradeGraphModeNone;
}

- (void)setGradeValuesWithAGrades:(NSInteger)aGrades BGrades:(NSInteger)bGrades CGrades:(NSInteger)cGrades DFGrades:(NSInteger)dfGrades
{
    CGFloat sum = (CGFloat)( aGrades + bGrades + cGrades + dfGrades );
    
    [self layoutIfNeeded];
    
    if( sum <= 0 )
    {
        self.gradeANumberLabel.text  = @"0";
        self.gradeBNumberLabel.text  = @"0";
        self.gradeCNumberLabel.text  = @"0";
        self.gradeDFNumberLabel.text = @"0";
        
        self.gradeAWidthConstraint = [self updateConstraint:self.gradeAWidthConstraint withNewMultiplier:0];
        self.gradeBWidthConstraint = [self updateConstraint:self.gradeBWidthConstraint withNewMultiplier:0];
        self.gradeCWidthConstraint = [self updateConstraint:self.gradeCWidthConstraint withNewMultiplier:0];
        self.gradeDWidthConstraint = [self updateConstraint:self.gradeDWidthConstraint withNewMultiplier:0];
        
        [self layoutIfNeeded];
        
        return;
    }
    
    CGFloat aMultiplier  = (CGFloat)aGrades  / sum;
    CGFloat bMultiplier  = (CGFloat)bGrades  / sum;
    CGFloat cMultiplier  = (CGFloat)cGrades  / sum;
    CGFloat dfMultiplier = (CGFloat)dfGrades / sum;
    
    self.gradeANumberLabel.text  = [NSString stringWithFormat:@"%d", (int)aGrades];
    self.gradeBNumberLabel.text  = [NSString stringWithFormat:@"%d", (int)bGrades];
    self.gradeCNumberLabel.text  = [NSString stringWithFormat:@"%d", (int)cGrades];
    self.gradeDFNumberLabel.text = [NSString stringWithFormat:@"%d", (int)dfGrades];
    
    self.gradeAWidthConstraint = [self updateConstraint:self.gradeAWidthConstraint withNewMultiplier:aMultiplier];
    self.gradeBWidthConstraint = [self updateConstraint:self.gradeBWidthConstraint withNewMultiplier:bMultiplier];
    self.gradeCWidthConstraint = [self updateConstraint:self.gradeCWidthConstraint withNewMultiplier:cMultiplier];
    self.gradeDWidthConstraint = [self updateConstraint:self.gradeDWidthConstraint withNewMultiplier:dfMultiplier];
    
    [self layoutIfNeeded];
}

- (NSLayoutConstraint *)updateConstraint:(NSLayoutConstraint *)constraint withNewMultiplier:(CGFloat)multiplier
{
    if( multiplier < 0.15f )
    {
        multiplier = 0.15f;
    }
    
    [self.contentView removeConstraint:constraint];
    
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:constraint.firstItem
                                                                     attribute:constraint.firstAttribute
                                                                     relatedBy:constraint.relation
                                                                        toItem:constraint.secondItem
                                                                     attribute:constraint.secondAttribute
                                                                    multiplier:multiplier
                                                                      constant:constraint.constant];
    
    [self.contentView addConstraint:newConstraint];
    
    return newConstraint;
}

- (void)moreButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(moreButtonTappedInGradeGraphCollectionViewCell:)] )
    {
        [self.delegate moreButtonTappedInGradeGraphCollectionViewCell:self];
    }
}

- (void)gradeBarButtonTapped:(UIButton *)button
{
    self.gradeABarButton.selected  = NO;
    self.gradeBBarButton.selected  = NO;
    self.gradeCBarButton.selected  = NO;
    self.gradeDFBarButton.selected = NO;
    
    if( [self.delegate respondsToSelector:@selector(gradeGraphCollectionViewCell:didSelectGradeGraphMode:)] )
    {
        if( button == self.gradeABarButton )
        {
            self.gradeABarButton.selected = self.gradeGraphMode == eGradeGraphModeA ? NO : YES;
            self.gradeGraphMode = self.gradeGraphMode == eGradeGraphModeA ? eGradeGraphModeNone : eGradeGraphModeA;
        }
        else if( button == self.gradeBBarButton )
        {
            self.gradeBBarButton.selected = self.gradeGraphMode == eGradeGraphModeB ? NO : YES;
            self.gradeGraphMode = self.gradeGraphMode == eGradeGraphModeB ? eGradeGraphModeNone : eGradeGraphModeB;
        }
        else if( button == self.gradeCBarButton )
        {
            self.gradeCBarButton.selected = self.gradeGraphMode == eGradeGraphModeC ? NO : YES;
            self.gradeGraphMode = self.gradeGraphMode == eGradeGraphModeC ? eGradeGraphModeNone : eGradeGraphModeC;
        }
        else if( button == self.gradeDFBarButton )
        {
            self.gradeDFBarButton.selected = self.gradeGraphMode == eGradeGraphModeDF ? NO : YES;
            self.gradeGraphMode = self.gradeGraphMode == eGradeGraphModeDF ? eGradeGraphModeNone : eGradeGraphModeDF;
        }
        
        [self.delegate gradeGraphCollectionViewCell:self didSelectGradeGraphMode:self.gradeGraphMode];
    }
}

- (void)beginLoading
{
    if( !self.overlayView )
    {
        self.overlayView = [[UIView alloc] initWithFrame:self.contentView.frame];
        self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }
    
    if( !self.spinner )
    {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.center = self.contentView.center;
        [self.spinner startAnimating];
    }
    
    [UIView transitionWithView:self.contentView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
    animations:^
    {
        [self.contentView addSubview:self.overlayView];
        [self.contentView addSubview:self.spinner];
    }
    completion:nil];
}

- (void)endLoading
{
    [UIView transitionWithView:self.contentView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
    animations:^
    {
        [self.overlayView removeFromSuperview];
        [self.spinner removeFromSuperview];
    }
    completion:nil];
}

@end
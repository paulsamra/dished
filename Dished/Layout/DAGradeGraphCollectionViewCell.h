//
//  DAGradesGraphCollectionViewCell.h
//  Dished
//
//  Created by Ryan Khalili on 12/14/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    eGradeGraphModeA,
    eGradeGraphModeB,
    eGradeGraphModeC,
    eGradeGraphModeDF,
    eGradeGraphModeNone
} eGradeGraphMode;

@class DAGradeGraphCollectionViewCell;

@protocol DAGradesGraphCollectionViewCellDelegate <NSObject>

@optional
- (void)gradeGraphCollectionViewCell:(DAGradeGraphCollectionViewCell *)cell didSelectGradeGraphMode:(eGradeGraphMode)gradeGraphMode;
- (void)moreButtonTappedInGradeGraphCollectionViewCell:(DAGradeGraphCollectionViewCell *)cell;

@end

@interface DAGradeGraphCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<DAGradesGraphCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel  *gradeANumberLabel;
@property (weak, nonatomic) IBOutlet UILabel  *gradeBNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel  *gradeCNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel  *gradeDFNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *gradeABarButton;
@property (weak, nonatomic) IBOutlet UIButton *gradeBBarButton;
@property (weak, nonatomic) IBOutlet UIButton *gradeCBarButton;
@property (weak, nonatomic) IBOutlet UIButton *gradeDFBarButton;

@property (nonatomic) eGradeGraphMode gradeGraphMode;

- (void)setGradeValuesWithAGrades:(NSInteger)aGrades BGrades:(NSInteger)bGrades CGrades:(NSInteger)cGrades DFGrades:(NSInteger)dfGrades;
- (void)beginLoading;
- (void)endLoading;

@end